# rentals/serializers.py

from rest_framework import serializers
from django.utils import timezone

from core.models import User
from .models import (
    Renter,
    Car,
    CarAvailability,
    CarRent,
    Parking,
    ParkingAvailability,
    ParkingRent,
    Insurance
)

#
# 1. RenterSerializer
#
class RenterSerializer(serializers.ModelSerializer):
    """
    Serializador para el perfil de Renter (herencia de User).
    - El campo `user` aparece como read-only; se asume que se crea
      automáticamente cuando el User se registra y se asocia a un Renter.
    - Los campos driver_license_image y photo_id_image esperan URLs de archivos subidos.
    """

    user = serializers.PrimaryKeyRelatedField(read_only=True)
    verified_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = Renter
        fields = [
            'id',
            'user',
            'driver_license_image',
            'photo_id_image',
            'is_verified',
            'verified_at',
        ]


#
# 2. CarSerializer
#
class CarSerializer(serializers.ModelSerializer):
    """
    Serializador para Car.
    - `owner` se marca como read_only; el ViewSet debe asignar owner desde request.user.renter_profile.
    - Las imágenes y el documento de registro retornan URL una vez subidos.
    """

    owner = serializers.PrimaryKeyRelatedField(read_only=True)
    image_front = serializers.ImageField(required=True)
    image_rear = serializers.ImageField(required=True)
    image_interior = serializers.ImageField(required=True)
    registration_document = serializers.FileField(required=True)

    class Meta:
        model = Car
        fields = [
            'id',
            'owner',
            'make',
            'model',
            'year',
            'description',
            'image_front',
            'image_rear',
            'image_interior',
            'registration_document',
            'daily_rate',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['created_at', 'updated_at']

    def create(self, validated_data):
        """
        Override para asignar automáticamente el owner basado en request.user.renter_profile.
        Se espera que la vista proporcione `context={'request': request}`.
        """
        request = self.context.get('request')
        if not request or not hasattr(request.user, 'renter_profile'):
            raise serializers.ValidationError(
                'Solo un Renter autenticado puede crear un Car.'
            )
        renter_profile = request.user.renter_profile
        validated_data['owner'] = renter_profile
        return super().create(validated_data)

    def update(self, instance, validated_data):
        """
        El propietario no puede cambiarse; ignoramos owner en update.
        """
        validated_data.pop('owner', None)
        return super().update(instance, validated_data)


#
# 3. CarAvailabilitySerializer
#
class CarAvailabilitySerializer(serializers.ModelSerializer):
    """
    Serializador para CarAvailability.
    - Fusiona automáticamente los rangos que se solapen o sean contiguos
      al crear o actualizar un registro.
    """
    class Meta:
        model = CarAvailability
        fields = ['id', 'car', 'start_datetime', 'end_datetime']

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end   = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        # 1) Creamos provisionalmente el nuevo bloque
        car   = validated_data['car']
        s_new = validated_data['start_datetime']
        e_new = validated_data['end_datetime']

        # 2) Recolectamos y eliminamos todos los bloque existentes que se solapen o toquen
        overlapping = CarAvailability.objects.filter(
            car=car,
            start_datetime__lte=e_new,
            end_datetime__gte=s_new
        )
        for blk in overlapping:
            s_new = min(s_new, blk.start_datetime)
            e_new = max(e_new, blk.end_datetime)
            blk.delete()

        # 3) Insertamos el bloque fusionado
        return CarAvailability.objects.create(
            car=car,
            start_datetime=s_new,
            end_datetime=e_new
        )

    def update(self, instance, validated_data):
        # Para simplificar, hacemos delete + create con la misma lógica de create()
        instance.delete()
        return self.create(validated_data)


from django.db import transaction

#
# 4. CarRentSerializer
#
class CarRentSerializer(serializers.ModelSerializer):
    """
    Serializador para CarRent.
    - Comprueba validez de fechas.
    - Valida que exista un único bloque de disponibilidad que cubra el rango.
    - Particiona ese bloque en 0/1/2 sub-bloques al crear la reserva.
    """
    renter = serializers.PrimaryKeyRelatedField(read_only=True)
    total_price = serializers.DecimalField(
        max_digits=12, decimal_places=2, required=False
    )
    status = serializers.ChoiceField(
        choices=CarRent.STATUS_CHOICES, default='pending'
    )

    class Meta:
        model = CarRent
        fields = [
            'id', 'car', 'renter',
            'start_datetime', 'end_datetime',
            'total_price', 'status',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['renter', 'created_at', 'updated_at']

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end   = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        request = self.context.get('request')
        user    = getattr(request, 'user', None)
        if not user or not user.is_authenticated:
            raise serializers.ValidationError('Usuario no autenticado.')

        # 1) Asignar renter
        try:
            renter_profile = user.renter_profile
        except Renter.DoesNotExist:
            raise serializers.ValidationError(
                'Solo usuarios con perfil Renter pueden rentar un vehículo.'
            )
        if not renter_profile.is_verified:
            raise serializers.ValidationError(
                'El usuario debe estar verificado para rentar un vehículo.'
            )
        validated_data['renter'] = user

        # 2) Chequear disponibilidad única
        car     = validated_data['car']
        s0, e0  = validated_data['start_datetime'], validated_data['end_datetime']
        avail_q = CarAvailability.objects.filter(
            car=car,
            start_datetime__lte=s0,
            end_datetime__gte=e0
        )
        if avail_q.count() != 1:
            raise serializers.ValidationError(
                'No existe exactamente una disponibilidad que cubra ese período.'
            )
        avail = avail_q.first()

        # 3) Evitar solapamiento con otras reservas activas
        if CarRent.objects.filter(
            car=car,
            status__in=['pending','confirmed','in_progress'],
            start_datetime__lt=e0,
            end_datetime__gt=s0
        ).exists():
            raise serializers.ValidationError(
                'Ya existe una reserva solapada en ese período.'
            )

        # 4) Calcular precio si hace falta
        if not validated_data.get('total_price'):
            days = max((e0 - s0).days, 1)
            validated_data['total_price'] = car.daily_rate * days

        # 5) Crear reserva y particionar disponibilidad en una transacción
        with transaction.atomic():
            rent = super().create(validated_data)

            s1, e1 = avail.start_datetime, avail.end_datetime
            # borramos el bloque original
            avail.delete()

            # si quedó hueco a la izquierda
            if s1 < s0:
                CarAvailability.objects.create(
                    car=car,
                    start_datetime=s1,
                    end_datetime=s0
                )
            # si quedó hueco a la derecha
            if e0 < e1:
                CarAvailability.objects.create(
                    car=car,
                    start_datetime=e0,
                    end_datetime=e1
                )

            return rent

    def update(self, instance, validated_data):
        validated_data.pop('renter', None)
        return super().update(instance, validated_data)


#
# 5. ParkingSerializer
#
class ParkingSerializer(serializers.ModelSerializer):
    """
    Serializador para Parking.
    - `owner` se asigna automáticamente en create.
    """

    owner = serializers.PrimaryKeyRelatedField(read_only=True)
    image = serializers.ImageField(required=True)

    class Meta:
        model = Parking
        fields = [
            'id',
            'owner',
            'name',
            'address',
            'description',
            'image',
            'hourly_rate',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['created_at', 'updated_at']

    def create(self, validated_data):
        request = self.context.get('request')
        if not request or not hasattr(request.user, 'renter_profile'):
            raise serializers.ValidationError('Solo un Renter autenticado puede crear un Parking.')
        renter_profile = request.user.renter_profile
        validated_data['owner'] = renter_profile
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data.pop('owner', None)
        return super().update(instance, validated_data)

#
# 6. ParkingAvailabilitySerializer
#
class ParkingAvailabilitySerializer(serializers.ModelSerializer):
    """
    Serializador para ParkingAvailability.
    - Fusiona automáticamente los rangos que se solapen o sean contiguos
      al crear o actualizar un registro.
    """

    class Meta:
        model = ParkingAvailability
        fields = ['id', 'parking', 'start_datetime', 'end_datetime']

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end   = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        parking = validated_data['parking']
        s_new   = validated_data['start_datetime']
        e_new   = validated_data['end_datetime']

        # Recolectar todos los bloques que tocan o se solapan
        overlaps = ParkingAvailability.objects.filter(
            parking=parking,
            start_datetime__lte=e_new,
            end_datetime__gte=s_new
        )
        # Expandir los límites del nuevo bloque con los solapamientos
        for blk in overlaps:
            s_new = min(s_new, blk.start_datetime)
            e_new = max(e_new, blk.end_datetime)
            blk.delete()

        # Crear el bloque fusionado
        return ParkingAvailability.objects.create(
            parking=parking,
            start_datetime=s_new,
            end_datetime=e_new
        )

    def update(self, instance, validated_data):
        # Eliminamos el registro existente y delegamos en create()
        instance.delete()
        return self.create(validated_data)


#
# 7. ParkingRentSerializer
#
class ParkingRentSerializer(serializers.ModelSerializer):
    """
    Serializador para ParkingRent.
    - Comprueba validez de fechas.
    - Busca exactamente un ParkingAvailability que cubra el rango.
    - Evita solapamientos con otras reservas activas.
    - Particiona ese bloque de disponibilidad en hasta dos sub-bloques.
    """
    renter = serializers.PrimaryKeyRelatedField(read_only=True)
    total_price = serializers.DecimalField(
        max_digits=12, decimal_places=2, required=False
    )
    status = serializers.ChoiceField(
        choices=ParkingRent.STATUS_CHOICES, default='pending'
    )

    class Meta:
        model = ParkingRent
        fields = [
            'id', 'parking', 'renter',
            'start_datetime', 'end_datetime',
            'total_price', 'status',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['renter', 'created_at', 'updated_at']

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end   = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        request = self.context.get('request')
        user    = getattr(request, 'user', None)
        if not user or not user.is_authenticated:
            raise serializers.ValidationError('Usuario no autenticado.')

        # 1) Validar perfil Renter y verificación
        try:
            renter_profile = user.renter_profile
        except Renter.DoesNotExist:
            raise serializers.ValidationError(
                'Solo usuarios con perfil Renter pueden alquilar un parking.'
            )
        if not renter_profile.is_verified:
            raise serializers.ValidationError(
                'El usuario debe estar verificado para alquilar un parking.'
            )
        validated_data['renter'] = user

        # 2) Encontrar disponibilidad única que cubra el rango
        parking = validated_data['parking']
        s0, e0  = validated_data['start_datetime'], validated_data['end_datetime']
        avail_q = ParkingAvailability.objects.filter(
            parking=parking,
            start_datetime__lte=s0,
            end_datetime__gte=e0
        )
        if avail_q.count() != 1:
            raise serializers.ValidationError(
                'No existe exactamente una disponibilidad que cubra ese período.'
            )
        avail = avail_q.first()

        # 3) Evitar solapamientos con otras reservas activas
        if ParkingRent.objects.filter(
            parking=parking,
            status__in=['pending','confirmed','in_progress'],
            start_datetime__lt=e0,
            end_datetime__gt=s0
        ).exists():
            raise serializers.ValidationError(
                'Ya existe una reserva solapada en ese período.'
            )

        # 4) Calcular precio si no se proporcionó
        if not validated_data.get('total_price'):
            duration = e0 - s0
            hours = int(duration.total_seconds() // 3600)
            if duration.total_seconds() % 3600:
                hours += 1
            hours = max(hours, 1)
            validated_data['total_price'] = parking.hourly_rate * hours

        # 5) Crear reserva y ajustar disponibilidad
        with transaction.atomic():
            rent = super().create(validated_data)

            s1, e1 = avail.start_datetime, avail.end_datetime
            avail.delete()

            # Hueco a la izquierda
            if s1 < s0:
                ParkingAvailability.objects.create(
                    parking=parking,
                    start_datetime=s1,
                    end_datetime=s0
                )
            # Hueco a la derecha
            if e0 < e1:
                ParkingAvailability.objects.create(
                    parking=parking,
                    start_datetime=e0,
                    end_datetime=e1
                )

            return rent

    def update(self, instance, validated_data):
        # No permitir cambiar renter; recalcular precio si cambian fechas
        validated_data.pop('renter', None)
        return super().update(instance, validated_data)
    
#
# 8. InsuranceSerializer
#
class InsuranceSerializer(serializers.ModelSerializer):
    """
    Serializador para Insurance.
    - Solo se puede asociar a un CarRent o a un ParkingRent (exactamente uno).
    """

    car_rent = serializers.PrimaryKeyRelatedField(
        queryset=CarRent.objects.all(),
        required=False,
        allow_null=True
    )
    parking_rent = serializers.PrimaryKeyRelatedField(
        queryset=ParkingRent.objects.all(),
        required=False,
        allow_null=True
    )

    class Meta:
        model = Insurance
        fields = [
            'id',
            'policy_number',
            'provider_name',
            'coverage_details',
            'premium',
            'car_rent',
            'parking_rent',
            'created_at',
        ]
        read_only_fields = ['created_at']

    def validate(self, attrs):
        car_rent = attrs.get('car_rent')
        parking_rent = attrs.get('parking_rent')
        if bool(car_rent) == bool(parking_rent):
            raise serializers.ValidationError(
                'Debe asociar el seguro a un solo CarRent o ParkingRent, no a ambos ni a ninguno.'
            )
        return attrs
