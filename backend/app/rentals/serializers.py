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
    - `car` debe ser el ID del Car al que pertenece.
    - Se validan solapamientos en el modelo; sin embargo, aquí también
      podemos validar rangos de fecha/horario.
    """

    class Meta:
        model = CarAvailability
        fields = [
            'id',
            'car',
            'start_datetime',
            'end_datetime',
        ]

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs


#
# 4. CarRentSerializer
#
class CarRentSerializer(serializers.ModelSerializer):
    """
    Serializador para CarRent.
    - `car` se envía como ID del Car a rentar.
    - `renter` se asigna automáticamente desde request.user.
    - Calcula `total_price` si no se envía explícitamente.
    - El modelo hará validaciones adicionales en `clean()`.
    """

    renter = serializers.PrimaryKeyRelatedField(read_only=True)
    total_price = serializers.DecimalField(
        max_digits=12,
        decimal_places=2,
        required=False
    )
    status = serializers.ChoiceField(choices=CarRent.STATUS_CHOICES, default='pending')

    class Meta:
        model = CarRent
        fields = [
            'id',
            'car',
            'renter',
            'start_datetime',
            'end_datetime',
            'total_price',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['renter', 'created_at', 'updated_at']

    def validate(self, attrs):
        """
        1) Validar start < end.
        2) Es posible calcular el total_price provisional aquí, pero el modelo también lo hará.
        """
        start = attrs.get('start_datetime')
        end = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        """
        Asignar renter basado en request.user; dejar que el modelo calcule total_price en clean().
        """
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError('Usuario no autenticado.')

        # El usuario debe tener perfil de Renter
        try:
            renter_profile = request.user.renter_profile
        except Renter.DoesNotExist:
            raise serializers.ValidationError('Solo usuarios con perfil Renter pueden rentar un Car.')

        validated_data['renter'] = request.user
        # Si total_price no viene en validated_data, lo dejamos vacío para que el modelo lo calcule
        return super().create(validated_data)

    def update(self, instance, validated_data):
        """
        No permitir cambiar renter; calculamos total_price nuevamente si cambian fechas.
        """
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
    """

    class Meta:
        model = ParkingAvailability
        fields = [
            'id',
            'parking',
            'start_datetime',
            'end_datetime',
        ]

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs


#
# 7. ParkingRentSerializer
#
class ParkingRentSerializer(serializers.ModelSerializer):
    """
    Serializador para ParkingRent.
    - `parking` se envía como ID del Parking.
    - `renter` es read-only y se asigna desde request.user.
    - El cálculo de `total_price` se hará en el modelo.
    """

    renter = serializers.PrimaryKeyRelatedField(read_only=True)
    total_price = serializers.DecimalField(
        max_digits=12,
        decimal_places=2,
        required=False
    )
    status = serializers.ChoiceField(choices=ParkingRent.STATUS_CHOICES, default='pending')

    class Meta:
        model = ParkingRent
        fields = [
            'id',
            'parking',
            'renter',
            'start_datetime',
            'end_datetime',
            'total_price',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['renter', 'created_at', 'updated_at']

    def validate(self, attrs):
        start = attrs.get('start_datetime')
        end = attrs.get('end_datetime')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        return attrs

    def create(self, validated_data):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError('Usuario no autenticado.')

        try:
            renter_profile = request.user.renter_profile
        except Renter.DoesNotExist:
            raise serializers.ValidationError('Solo usuarios con perfil Renter pueden rentar un Parking.')

        validated_data['renter'] = request.user
        return super().create(validated_data)

    def update(self, instance, validated_data):
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
