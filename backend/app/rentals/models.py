# rentals/models.py

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone

User = settings.AUTH_USER_MODEL


class Renter(models.Model):
    """
    Herencia de tabla: cada Renter extiende a User para guardar
    información mínima de KYC (Know Your Customer).
    """
    # Relación uno a uno con el modelo User
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='renter_profile',
        help_text='Perfil de Renter asociado a un User.'
    )

    driver_license_image = models.ImageField(
        upload_to='kyc/licenses/',
        help_text='Foto de la licencia de conducir.',
        null=True,
        blank=True
    )
    photo_id_image = models.ImageField(
        upload_to='kyc/photo_ids/',
        help_text='Foto de identificación del usuario para verificación.',
        null=True,
        blank=True
    )
    is_verified = models.BooleanField(
        default=False,
        help_text='Indica si el Renter ha completado la verificación de identidad.'
    )
    verified_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Fecha y hora en que se completó la verificación.'
    )

    class Meta:
        verbose_name = 'Renter'
        verbose_name_plural = 'Renters'

    def clean(self):
        super().clean()
        if self.is_verified:
            missing = {}
            if not self.driver_license_image:
                missing['driver_license_image'] = 'Este campo es obligatorio para usuarios verificados.'
            if not self.photo_id_image:
                missing['photo_id_image'] = 'Este campo es obligatorio para usuarios verificados.'
            if missing:
                raise ValidationError(missing)

    def save(self, *args, **kwargs):
        if self.is_verified and not self.verified_at:
            self.verified_at = timezone.now()
        super().save(*args, **kwargs)

    def __str__(self):
        return f'Renter: {self.user.email}'


class Car(models.Model):
    """
    Representa un vehículo ofrecido en renta por un Renter.
    """
    owner = models.ForeignKey(
        Renter,
        on_delete=models.CASCADE,
        related_name='cars',
        help_text='El Renter que ofrece este vehículo.'
    )
    make = models.CharField(max_length=100, help_text='Marca del vehículo.')
    model = models.CharField(max_length=100, help_text='Modelo del vehículo.')
    year = models.PositiveSmallIntegerField(help_text='Año de fabricación.')
    description = models.TextField(
        blank=True,
        help_text='Descripción opcional del vehículo.'
    )

    image_front = models.ImageField(
        upload_to='cars/front/',
        help_text='Imagen frontal del vehículo.'
    )
    image_rear = models.ImageField(
        upload_to='cars/rear/',
        help_text='Imagen trasera del vehículo.'
    )
    image_interior = models.ImageField(
        upload_to='cars/interior/',
        help_text='Imagen del interior del vehículo.'
    )

    registration_document = models.FileField(
        upload_to='cars/registration_docs/',
        help_text='Documento que acredita la propiedad del vehículo.'
    )

    daily_rate = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text='Tarifa diaria de alquiler.'
    )

    is_active = models.BooleanField(
        default=True,
        help_text='Indica si el vehículo está disponible para renta.'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Car'
        verbose_name_plural = 'Cars'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.make} {self.model} ({self.year}) - Owner: {self.owner.user.email}'


class CarAvailability(models.Model):
    """
    Ventana de disponibilidad de un Car.
    """
    car = models.ForeignKey(
        Car,
        on_delete=models.CASCADE,
        related_name='availabilities'
    )
    start_datetime = models.DateTimeField(help_text='Inicio de la disponibilidad.')
    end_datetime = models.DateTimeField(help_text='Fin de la disponibilidad.')

    class Meta:
        verbose_name = 'Car Availability'
        verbose_name_plural = 'Cars Availability'
        ordering = ['car', 'start_datetime']

    def clean(self):
        super().clean()
        if self.end_datetime <= self.start_datetime:
            raise ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        overlapping = CarAvailability.objects.filter(car=self.car).exclude(pk=self.pk).filter(
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        )
        if overlapping.exists():
            raise ValidationError('Este periodo de disponibilidad se solapa con otro ya existente.')

    def __str__(self):
        return (
            f'Availability for {self.car.make} {self.car.model} '
            f'from {self.start_datetime} to {self.end_datetime}'
        )


class CarRent(models.Model):
    """
    Reserva de un Car por parte de un usuario (debe ser Renter verificado).
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    car = models.ForeignKey(
        Car,
        on_delete=models.CASCADE,
        related_name='rents'
    )
    renter = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='car_rentals',
        help_text='Usuario que realiza la renta.'
    )
    start_datetime = models.DateTimeField(help_text='Fecha y hora de inicio de la renta.')
    end_datetime = models.DateTimeField(help_text='Fecha y hora de fin de la renta.')

    total_price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        help_text='Precio total calculado: tarifa diaria × número de días.'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        help_text='Estado de la reserva.'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Car Rent'
        verbose_name_plural = 'Car Rents'
        ordering = ['-created_at']

    def clean(self):
        super().clean()

        # 1) El usuario debe tener perfil Renter y estar verificado
        try:
            renter_profile = self.renter.renter_profile
        except Renter.DoesNotExist:
            raise ValidationError('Solo usuarios con perfil Renter pueden rentar un vehículo.')
        if not renter_profile.is_verified:
            raise ValidationError('El usuario debe estar verificado para rentar un vehículo.')

        # 2) Fechas válidas
        if self.end_datetime <= self.start_datetime:
            raise ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })

        # 3) Verificar que exista CarAvailability que cubra completamente el rango
        valid_avail_qs = CarAvailability.objects.filter(
            car=self.car,
            start_datetime__lte=self.start_datetime,
            end_datetime__gte=self.end_datetime
        )
        if not valid_avail_qs.exists():
            raise ValidationError('No existe disponibilidad para este vehículo en el período solicitado.')

        # 4) Evitar solapamiento con otras reservas activas/pendientes
        overlapping_rents = CarRent.objects.filter(
            car=self.car,
            status__in=['pending', 'confirmed', 'in_progress']
        ).exclude(pk=self.pk).filter(
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        )
        if overlapping_rents.exists():
            raise ValidationError('Este vehículo ya está reservado en un período que se superpone.')

        # 5) Calcular precio total si no se proporciona
        if not self.total_price or self.total_price <= 0:
            days = (self.end_datetime - self.start_datetime).days
            days = days if days >= 1 else 1
            self.total_price = self.car.daily_rate * days

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return (
            f'CarRent: {self.car.make} {self.car.model} | '
            f'Client: {self.renter.email} | '
            f'From {self.start_datetime} to {self.end_datetime} | '
            f'Status: {self.status}'
        )


class Parking(models.Model):
    """
    Representa un espacio de estacionamiento ofrecido por un Renter.
    """
    owner = models.ForeignKey(
        Renter,
        on_delete=models.CASCADE,
        related_name='parkings',
        help_text='El Renter que ofrece este estacionamiento.'
    )
    name = models.CharField(
        max_length=150,
        help_text='Nombre o referencia del estacionamiento.'
    )
    address = models.CharField(
        max_length=255,
        help_text='Dirección física del estacionamiento.'
    )
    description = models.TextField(
        blank=True,
        help_text='Descripción opcional del parking (capacidad, características).'
    )

    image = models.ImageField(
        upload_to='parkings/images/',
        help_text='Imagen representativa del estacionamiento.'
    )

    hourly_rate = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text='Tarifa por hora de estacionamiento.'
    )

    is_active = models.BooleanField(
        default=True,
        help_text='Indica si el parking está disponible para renta.'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Parking'
        verbose_name_plural = 'Parkings'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.name} – {self.address}'


class ParkingAvailability(models.Model):
    """
    Ventana de disponibilidad de un Parking.
    """
    parking = models.ForeignKey(
        Parking,
        on_delete=models.CASCADE,
        related_name='availabilities'
    )
    start_datetime = models.DateTimeField(help_text='Inicio de la disponibilidad.')
    end_datetime = models.DateTimeField(help_text='Fin de la disponibilidad.')

    class Meta:
        verbose_name = 'Parking Availability'
        verbose_name_plural = 'Parkings Availability'
        ordering = ['parking', 'start_datetime']

    def clean(self):
        super().clean()
        if self.end_datetime <= self.start_datetime:
            raise ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })
        overlapping = ParkingAvailability.objects.filter(parking=self.parking).exclude(pk=self.pk).filter(
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        )
        if overlapping.exists():
            raise ValidationError('Este período de disponibilidad se solapa con otro existente.')

    def __str__(self):
        return (
            f'Availability for Parking "{self.parking.name}" '
            f'from {self.start_datetime} to {self.end_datetime}'
        )


class ParkingRent(models.Model):
    """
    Reserva de un Parking por parte de un usuario (debe ser Renter verificado).
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    parking = models.ForeignKey(
        Parking,
        on_delete=models.CASCADE,
        related_name='rents'
    )
    renter = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='parking_rentals',
        help_text='Usuario que realiza el alquiler de parking.'
    )
    start_datetime = models.DateTimeField(help_text='Inicio de la renta (fecha y hora).')
    end_datetime = models.DateTimeField(help_text='Fin de la renta (fecha y hora).')

    total_price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        help_text='Precio total calculado: tarifa por hora × número de horas.'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        help_text='Estado de la reserva.'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Parking Rent'
        verbose_name_plural = 'Parking Rents'
        ordering = ['-created_at']

    def clean(self):
        super().clean()

        # 1) Verificar perfil Renter y que esté verificado
        try:
            renter_profile = self.renter.renter_profile
        except Renter.DoesNotExist:
            raise ValidationError('Solo usuarios con perfil Renter pueden alquilar un parking.')
        if not renter_profile.is_verified:
            raise ValidationError('El usuario debe estar verificado para alquilar un parking.')

        # 2) Fechas válidas
        if self.end_datetime <= self.start_datetime:
            raise ValidationError({
                'end_datetime': 'La fecha/hora de fin debe ser posterior a la de inicio.'
            })

        # 3) Verificar disponibilidad que cubra el rango
        valid_avail = ParkingAvailability.objects.filter(
            parking=self.parking,
            start_datetime__lte=self.start_datetime,
            end_datetime__gte=self.end_datetime
        )
        if not valid_avail.exists():
            raise ValidationError('No hay disponibilidad para ese parking en el período solicitado.')

        # 4) Evitar solapamiento con otras reservas activas/pendientes
        overlapping_rents = ParkingRent.objects.filter(
            parking=self.parking,
            status__in=['pending', 'confirmed', 'in_progress']
        ).exclude(pk=self.pk).filter(
            start_datetime__lt=self.end_datetime,
            end_datetime__gt=self.start_datetime
        )
        if overlapping_rents.exists():
            raise ValidationError('Este espacio de parking ya está reservado en el período solicitado.')

        # 5) Calcular precio total si no se proporciona
        duration = self.end_datetime - self.start_datetime
        hours = int(duration.total_seconds() // 3600)
        if duration.total_seconds() % 3600:
            hours += 1
        hours = max(hours, 1)
        if not self.total_price or self.total_price <= 0:
            self.total_price = self.parking.hourly_rate * hours

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return (
            f'ParkingRent: {self.parking.name} | '
            f'Client: {self.renter.email} | '
            f'From {self.start_datetime} to {self.end_datetime} | '
            f'Status: {self.status}'
        )


class Insurance(models.Model):
    """
    Seguro asociado a un CarRent o a un ParkingRent (exactamente uno).
    """
    policy_number = models.CharField(
        max_length=100,
        unique=True,
        help_text='Número de póliza.'
    )
    provider_name = models.CharField(
        max_length=150,
        help_text='Nombre de la aseguradora.'
    )
    coverage_details = models.TextField(
        blank=True,
        help_text='Detalle de la cobertura.'
    )
    premium = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text='Costo del seguro.'
    )

    car_rent = models.OneToOneField(
        CarRent,
        on_delete=models.CASCADE,
        related_name='insurance',
        null=True,
        blank=True
    )
    parking_rent = models.OneToOneField(
        ParkingRent,
        on_delete=models.CASCADE,
        related_name='insurance',
        null=True,
        blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Insurance'
        verbose_name_plural = 'Insurances'

    def clean(self):
        super().clean()
        if bool(self.car_rent) == bool(self.parking_rent):
            raise ValidationError(
                'Debe asociar el seguro a un solo CarRent o ParkingRent, no a ambos ni a ninguno.'
            )

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        target = self.car_rent or self.parking_rent
        tipo = 'CarRent' if self.car_rent else 'ParkingRent'
        return f'Insurance {self.policy_number} ({tipo} #{target.pk})'
