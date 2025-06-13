# rentals/views.py

from django.db import transaction
from django.shortcuts import get_object_or_404
from django.core.exceptions import ValidationError as DjangoValidationError
from django.contrib.auth import models

from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response    
from django.utils import timezone

from drf_spectacular.utils import (
    extend_schema,
    OpenApiParameter,
    OpenApiExample,
)
from drf_spectacular.types import OpenApiTypes

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
from .serializers import (
    RenterSerializer,
    CarSerializer,
    CarAvailabilitySerializer,
    CarRentSerializer,
    ParkingSerializer,
    ParkingAvailabilitySerializer,
    ParkingRentSerializer,
    InsuranceSerializer
)
from .permissions import (
    IsVerifiedRenter,
    IsOwnerOfCar,
    IsOwnerOfParking,
)



class VerifyRenterAPIView(APIView):
    """
    POST: Mark a given Renter’s profile as verified. 
          - Only staff users (is_staff=True) may call this.
          - The target Renter must already have both driver_license_image and photo_id_image present.
    """
    permission_classes = [permissions.IsAuthenticated, permissions.IsAdminUser]

    @extend_schema(
        tags=['Renter'],
        parameters=[
            OpenApiParameter(
                name='renter_id',
                location=OpenApiParameter.PATH,
                description='ID of the Renter to versify.',
                required=True,
                type=OpenApiTypes.INT
            )
        ],
        responses={
            200: RenterSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Staff-only endpoint to mark a Renter as “verified” after checking that both required images are present.'
    )
    def post(self, request, renter_id: int):
        # Get the Renter profile, 404 if not found
        renter_profile = get_object_or_404(Renter, user__id=renter_id)

        # Prevent re-verifying if already verified
        if renter_profile.is_verified:
            return Response(
                {"detail": "Este perfil ya está verificado."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Ensure both documents are uploaded
        if not renter_profile.driver_license_image or not renter_profile.photo_id_image:
            return Response(
                {"detail": "El Renter debe tener la licencia y la foto de identificación cargadas antes de verificar."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Within a transaction, mark is_verified=True
        try:
            with transaction.atomic():
                renter_profile.is_verified = True
                renter_profile.save()
                return Response(RenterSerializer(renter_profile).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

#
# 1. Renter Profile (Create & Retrieve/Update)
#
class RenterProfileAPIView(APIView):
    """
    GET: Retrieve the authenticated user's Renter profile (if exists).
    POST: Create Renter profile for the authenticated user.
    PUT: Update own Renter profile (cannot change `is_verified` unless staff).
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Renter'],
        responses={200: RenterSerializer},
        description='Retrieve the authenticated user’s Renter profile.',
    )
    def get(self, request):
        try:
            profile = request.user.renter_profile
        except Renter.DoesNotExist:
            return Response(
                {"detail": "No existe perfil de Renter para este usuario."},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = RenterSerializer(profile)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @extend_schema(
        tags=['Renter'],
        request=RenterSerializer,
        responses={
            201: RenterSerializer,
            400: OpenApiTypes.OBJECT
        },
        description='Create a Renter profile for the authenticated user. '
                    'Requires uploading driver_license_image and photo_id_image.'
    )
    def post(self, request):
        if hasattr(request.user, 'renter_profile'):
            return Response(
                {"detail": "Ya existe un perfil de Renter para este usuario."},
                status=status.HTTP_400_BAD_REQUEST
            )
        serializer = RenterSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                profile = serializer.save(user=request.user)
                return Response(RenterSerializer(profile).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Renter'],
        request=RenterSerializer,
        responses={
            200: RenterSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Update the authenticated user’s Renter profile. '
                    'A non-staff user cannot modify `is_verified`.'
    )
    def put(self, request):
        try:
            profile = request.user.renter_profile
        except Renter.DoesNotExist:
            return Response(
                {"detail": "No existe perfil de Renter para este usuario."},
                status=status.HTTP_404_NOT_FOUND
            )
        # Prevent normal users from toggling is_verified
        if 'is_verified' in request.data and not request.user.is_staff:
            return Response(
                {"detail": "No tienes permiso para modificar el campo is_verified."},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = RenterSerializer(profile, data=request.data, partial=False)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(RenterSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


#
# 2. Car Endpoints
#

class RegisterCarAPIView(APIView):
    """
    POST: Register a new Car under the authenticated Renter (must be verified).
    """
    permission_classes = [permissions.IsAuthenticated, IsVerifiedRenter]

    @extend_schema(
        tags=['Cars'],
        request=CarSerializer,
        responses={
            201: CarSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Register a new Car. Requires owner to be a verified Renter. '
                    'Fields: make, model, year, description (optional), '
                    'image_front, image_rear, image_interior, registration_document, daily_rate.'
    )
    def post(self, request):
        serializer = CarSerializer(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                car = serializer.save()
                return Response(CarSerializer(car).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListCarsAPIView(APIView):
    """
    GET: List all active Cars.
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Cars'],
        responses={200: CarSerializer(many=True)},
        description='List all active Cars available for rental.'
    )
    def get(self, request):
        cars = Car.objects.filter(is_active=True)
        serializer = CarSerializer(cars, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class ListAvailableCarsAPIView(APIView):
    """
    GET: Devuelve todos los vehículos activos que tienen al menos
         una ventana de disponibilidad futura (no consumida por reservas).
    """
    permission_classes = []

    @extend_schema(
        tags=['Cars'],
        responses={
            200: CarSerializer(many=True),
            403: OpenApiTypes.OBJECT
        },
        description=(
            'Lista todos los Cars con al menos una disponibilidad restante. '
            'Se consideran únicamente ventanas cuya end_datetime sea posterior a ahora. '
            'Requiere autenticación.'
        )
    )
    def get(self, request):
        ahora = timezone.now()
        # Filtramos Cars activos que tengan al menos una CarAvailability con end > ahora
        cars_qs = Car.objects.filter(
            is_active=True,
            availabilities__end_datetime__gt=ahora
        ).distinct()

        serializer = CarSerializer(cars_qs, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class UpdateDeleteCarAPIView(APIView):
    """
    PUT: Update own Car (owner only).
    DELETE: Deactivate (soft-delete) own Car (owner only).
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfCar]

    @extend_schema(
        tags=['Cars'],
        request=CarSerializer,
        responses={
            200: CarSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Update fields of an existing Car. Only the owner may update.'
    )
    def put(self, request, car_id: int):
        car = get_object_or_404(Car, pk=car_id, is_active=True)
        self.check_object_permissions(request, car)
        data = request.data.copy()
        data.pop('owner', None)  # Prevent changing owner
        serializer = CarSerializer(car, data=data, partial=False, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(CarSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Cars'],
        responses={
            204: OpenApiTypes.NONE,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Deactivate (soft-delete) a Car. Only the owner may deactivate.'
    )
    def delete(self, request, car_id: int):
        car = get_object_or_404(Car, pk=car_id, is_active=True)
        self.check_object_permissions(request, car)
        car.is_active = False
        car.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


#
# 3. Car Availability Endpoints
#

class CreateCarAvailabilityAPIView(APIView):
    """
    POST: Create a new availability window for a specific Car.
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfCar]

    @extend_schema(
        tags=['Car Availability'],
        request=CarAvailabilitySerializer,
        responses={
            201: CarAvailabilitySerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Create a new availability window for a Car. '
                    'Fields: car (ID), start_datetime (ISO8601), end_datetime (ISO8601).'
    )
    def post(self, request):
        serializer = CarAvailabilitySerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        car = get_object_or_404(Car, pk=serializer.validated_data['car'].id, is_active=True)
        if car.owner != request.user.renter_profile:
            return Response(
                {"detail": "No eres el propietario de este Car."},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            with transaction.atomic():
                availability = serializer.save()
                return Response(CarAvailabilitySerializer(availability).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListCarAvailabilityAPIView(APIView):
    """
    GET: List availability windows for a specific Car.
    Query param: car_id (required)
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Car Availability'],
        parameters=[
            OpenApiParameter(
                name='car_id',
                description='ID of the Car for which to list availability.',
                required=True,
                type=OpenApiTypes.INT
            )
        ],
        responses={200: CarAvailabilitySerializer(many=True)},
        description='List all availability windows for a given Car.'
    )
    def get(self, request):
        car_id = request.query_params.get('car_id')
        if not car_id:
            return Response(
                {"detail": "Falta el parámetro car_id."},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            car = Car.objects.get(pk=car_id, is_active=True)
        except Car.DoesNotExist:
            return Response(
                {"detail": "Car no encontrado o inactivo."},
                status=status.HTTP_404_NOT_FOUND
            )
        availabilities = CarAvailability.objects.filter(car=car).order_by('start_datetime')
        serializer = CarAvailabilitySerializer(availabilities, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


#
# 4. Car Rental Endpoints
#
class BookCarAPIView(APIView):
    """
    POST: Request a new CarRent (book a Car).
    """
    permission_classes = [permissions.IsAuthenticated, IsVerifiedRenter]

    @extend_schema(
        tags=['Car Rentals'],
        request=CarRentSerializer,
        responses={
            201: CarRentSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Book a Car for a specified period. '
                    'Fields: car (ID), start_datetime (ISO8601), end_datetime (ISO8601). '
                    'Total_price and status are computed automatically.'
    )
    def post(self, request):
        serializer = CarRentSerializer(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                rent = serializer.save(renter=request.user)
                return Response(CarRentSerializer(rent).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

class ListOwnCarRentalsAPIView(APIView):
    """
    GET: List all CarRentals belonging to the authenticated user.
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Car Rentals'],
        responses={200: CarRentSerializer(many=True)},
        description='List all CarRent records for the authenticated user.'
    )
    def get(self, request):
        rents = CarRent.objects.filter(renter=request.user).order_by('-created_at')
        serializer = CarRentSerializer(rents, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateCancelCarRentalAPIView(APIView):
    """
    PUT: Update an existing CarRent (if status pending or confirmed).
    DELETE: Cancel a CarRent (set status to 'cancelled', if allowed).
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfCar]

    @extend_schema(
        tags=['Car Rentals'],
        request=CarRentSerializer,
        responses={
            200: CarRentSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Update fields of a CarRent. Only allowed if status is pending or confirmed.'
    )
    def put(self, request, rent_id: int):
        rent = get_object_or_404(CarRent, pk=rent_id, renter=request.user)
        if rent.status not in ['pending', 'confirmed']:
            return Response(
                {"detail": "No puedes modificar una reserva que ya está en curso o finalizada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        serializer = CarRentSerializer(rent, data=request.data, partial=False, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(CarRentSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Car Rentals'],
        responses={
            204: OpenApiTypes.NONE,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Cancel a CarRent by setting its status to “cancelled”. '
                    'Only possible if status is pending or confirmed.'
    )
    def delete(self, request, rent_id: int):
        rent = get_object_or_404(CarRent, pk=rent_id, renter=request.user)
        if rent.status not in ['pending', 'confirmed']:
            return Response(
                {"detail": "No puedes cancelar una reserva que ya está en curso o finalizada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        rent.status = 'cancelled'
        rent.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


#
# 5. Parking Endpoints
#

class RegisterParkingAPIView(APIView):
    """
    POST: Register a new Parking under the authenticated Renter (must be verified).
    """
    permission_classes = [permissions.IsAuthenticated, IsVerifiedRenter]

    @extend_schema(
        tags=['Parkings'],
        request=ParkingSerializer,
        responses={
            201: ParkingSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Register a new Parking. Requires owner to be a verified Renter. '
                    'Fields: name, address, description (optional), image, hourly_rate.'
    )
    def post(self, request):
        serializer = ParkingSerializer(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            with transaction.atomic():
                parking = serializer.save()
                return Response(ParkingSerializer(parking).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListParkingsAPIView(APIView):
    """
    GET: List all active Parkings.
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Parkings'],
        responses={200: ParkingSerializer(many=True)},
        description='List all active Parkings available for rental.'
    )
    def get(self, request):
        parkings = Parking.objects.filter(is_active=True)
        serializer = ParkingSerializer(parkings, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class ListAvailableParkingsAPIView(APIView):
    """
    GET: Devuelve todos los parkings activos que tienen al menos
         una ventana de disponibilidad futura (no consumida por reservas).
    """
    permission_classes = []

    @extend_schema(
        tags=['Parkings'],
        responses={
            200: ParkingSerializer(many=True),
            403: OpenApiTypes.OBJECT
        },
        description=(
            'Lista todos los Parkings con al menos una disponibilidad restante. '
            'Se consideran únicamente ventanas cuya end_datetime sea posterior a ahora. '
            'Requiere autenticación.'
        )
    )
    def get(self, request):
        ahora = timezone.now()
        # Filtramos parkings activos que tengan al menos una ParkingAvailability con end > ahora
        parkings_qs = Parking.objects.filter(
            is_active=True,
            availabilities__end_datetime__gt=ahora
        ).distinct()

        serializer = ParkingSerializer(parkings_qs, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class UpdateDeleteParkingAPIView(APIView):
    """
    PUT: Update own Parking (owner only).
    DELETE: Deactivate (soft-delete) own Parking (owner only).
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfParking]

    @extend_schema(
        tags=['Parkings'],
        request=ParkingSerializer,
        responses={
            200: ParkingSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Update fields of an existing Parking. Only the owner may update.'
    )
    def put(self, request, parking_id: int):
        parking = get_object_or_404(Parking, pk=parking_id, is_active=True)
        self.check_object_permissions(request, parking)
        data = request.data.copy()
        data.pop('owner', None)
        serializer = ParkingSerializer(parking, data=data, partial=False, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(ParkingSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Parkings'],
        responses={
            204: OpenApiTypes.NONE,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Deactivate (soft-delete) a Parking. Only the owner may deactivate.'
    )
    def delete(self, request, parking_id: int):
        parking = get_object_or_404(Parking, pk=parking_id, is_active=True)
        self.check_object_permissions(request, parking)
        parking.is_active = False
        parking.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


#
# 6. Parking Availability Endpoints
#

class CreateParkingAvailabilityAPIView(APIView):
    """
    POST: Create a new availability window for a specific Parking.
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfParking]

    @extend_schema(
        tags=['Parking Availability'],
        request=ParkingAvailabilitySerializer,
        responses={
            201: ParkingAvailabilitySerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Create a new availability window for a Parking. '
                    'Fields: parking (ID), start_datetime (ISO8601), end_datetime (ISO8601).'
    )
    def post(self, request):
        serializer = ParkingAvailabilitySerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        parking = get_object_or_404(Parking, pk=serializer.validated_data['parking'].id, is_active=True)
        if parking.owner != request.user.renter_profile:
            return Response(
                {"detail": "No eres el propietario de este Parking."},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            with transaction.atomic():
                availability = serializer.save()
                return Response(ParkingAvailabilitySerializer(availability).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListParkingAvailabilityAPIView(APIView):
    """
    GET: List availability windows for a specific Parking.
    Query param: parking_id (required)
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Parking Availability'],
        parameters=[
            OpenApiParameter(
                name='parking_id',
                description='ID of the Parking for which to list availability.',
                required=True,
                type=OpenApiTypes.INT
            )
        ],
        responses={200: ParkingAvailabilitySerializer(many=True)},
        description='List all availability windows for a given Parking.'
    )
    def get(self, request):
        parking_id = request.query_params.get('parking_id')
        if not parking_id:
            return Response(
                {"detail": "Falta el parámetro parking_id."},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            parking = Parking.objects.get(pk=parking_id, is_active=True)
        except Parking.DoesNotExist:
            return Response(
                {"detail": "Parking no encontrado o inactivo."},
                status=status.HTTP_404_NOT_FOUND
            )
        availabilities = ParkingAvailability.objects.filter(parking=parking).order_by('start_datetime')
        serializer = ParkingAvailabilitySerializer(availabilities, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


#
# 7. Parking Rental Endpoints
#

class BookParkingAPIView(APIView):
    """
    POST: Request a new ParkingRent (book a Parking).
    """
    permission_classes = [permissions.IsAuthenticated, IsVerifiedRenter]

    @extend_schema(
        tags=['Parking Rentals'],
        request=ParkingRentSerializer,
        responses={
            201: ParkingRentSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Book a Parking for a specified period. '
                    'Fields: parking (ID), start_datetime (ISO8601), end_datetime (ISO8601). '
                    'Total_price and status are computed automatically.'
    )
    def post(self, request):
        serializer = ParkingRentSerializer(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                rent = serializer.save(renter=request.user)
                return Response(ParkingRentSerializer(rent).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListOwnParkingRentalsAPIView(APIView):
    """
    GET: List all ParkingRentals belonging to the authenticated user.
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Parking Rentals'],
        responses={200: ParkingRentSerializer(many=True)},
        description='List all ParkingRent records for the authenticated user.'
    )
    def get(self, request):
        rents = ParkingRent.objects.filter(renter=request.user).order_by('-created_at')
        serializer = ParkingRentSerializer(rents, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateCancelParkingRentalAPIView(APIView):
    """
    PUT: Update an existing ParkingRent (if status pending or confirmed).
    DELETE: Cancel a ParkingRent (set status to 'cancelled', if allowed).
    """
    permission_classes = [permissions.IsAuthenticated, IsOwnerOfParking]

    @extend_schema(
        tags=['Parking Rentals'],
        request=ParkingRentSerializer,
        responses={
            200: ParkingRentSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Update fields of a ParkingRent. Only allowed if status is pending or confirmed.'
    )
    def put(self, request, rent_id: int):
        rent = get_object_or_404(ParkingRent, pk=rent_id, renter=request.user)
        if rent.status not in ['pending', 'confirmed']:
            return Response(
                {"detail": "No puedes modificar una reserva que ya está en curso o finalizada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        serializer = ParkingRentSerializer(rent, data=request.data, partial=False, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(ParkingRentSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Parking Rentals'],
        responses={
            204: OpenApiTypes.NONE,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Cancel a ParkingRent by setting its status to “cancelled”. '
                    'Only possible if status is pending or confirmed.'
    )
    def delete(self, request, rent_id: int):
        rent = get_object_or_404(ParkingRent, pk=rent_id, renter=request.user)
        if rent.status not in ['pending', 'confirmed']:
            return Response(
                {"detail": "No puedes cancelar una reserva que ya está en curso o finalizada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        rent.status = 'cancelled'
        rent.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


#
# 8. Insurance Endpoints
#

class PurchaseInsuranceAPIView(APIView):
    """
    POST: Purchase an Insurance for an existing CarRent or ParkingRent.
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Insurance'],
        request=InsuranceSerializer,
        responses={
            201: InsuranceSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT
        },
        description='Purchase an insurance policy linked to a CarRent or ParkingRent. '
                    'Fields: policy_number, provider_name, coverage_details (optional), premium, '
                    'car_rent (ID, optional), parking_rent (ID, optional).'
    )
    def post(self, request):
        serializer = InsuranceSerializer(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        car_rent = serializer.validated_data.get('car_rent')
        parking_rent = serializer.validated_data.get('parking_rent')

        # Verify ownership: user must be the renter of the associated rental
        if car_rent:
            if car_rent.renter != request.user:
                return Response(
                    {"detail": "No puedes comprar seguro para una reserva de carro que no te pertenece."},
                    status=status.HTTP_403_FORBIDDEN
                )
        else:
            if parking_rent.renter != request.user:
                return Response(
                    {"detail": "No puedes comprar seguro para una reserva de parking que no te pertenece."},
                    status=status.HTTP_403_FORBIDDEN
                )

        try:
            with transaction.atomic():
                insurance = serializer.save()
                return Response(InsuranceSerializer(insurance).data, status=status.HTTP_201_CREATED)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)


class ListOwnInsurancesAPIView(APIView):
    """
    GET: List all Insurance policies of the authenticated user (for their rentals).
    """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=['Insurance'],
        responses={200: InsuranceSerializer(many=True)},
        description='List all Insurance policies associated with the authenticated user’s rentals.'
    )
    def get(self, request):
        insurances = Insurance.objects.filter(
            models.Q(car_rent__renter=request.user) |
            models.Q(parking_rent__renter=request.user)
        ).order_by('-created_at')
        serializer = InsuranceSerializer(insurances, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateDeleteInsuranceAPIView(APIView):
    """
    PUT: Update an Insurance (only if associated rental status in ['pending','confirmed','in_progress']).
    DELETE: Delete an Insurance (same restriction).
    """
    permission_classes = [permissions.IsAuthenticated,]

    @extend_schema(
        tags=['Insurance'],
        request=InsuranceSerializer,
        responses={
            200: InsuranceSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Update fields of an Insurance. Only allowed if associated rental is pending, confirmed, or in_progress.'
    )
    def put(self, request, insurance_id: int):
        insurance = get_object_or_404(
            Insurance,
            # Filtro posicional primero
            models.Q(car_rent__renter=request.user) | models.Q(parking_rent__renter=request.user),
            # Después, el filtro por pk
            pk=insurance_id
        )
        linked_rental = insurance.car_rent or insurance.parking_rent
        if linked_rental.status not in ['pending', 'confirmed', 'in_progress']:
            return Response(
                {"detail": "No puedes modificar el seguro de una reserva finalizada o cancelada."},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = InsuranceSerializer(insurance, data=request.data, partial=False, context={'request': request})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                updated = serializer.save()
                return Response(InsuranceSerializer(updated).data, status=status.HTTP_200_OK)
        except DjangoValidationError as e:
            return Response(e.message_dict, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        tags=['Insurance'],
        responses={
            204: OpenApiTypes.NONE,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT
        },
        description='Delete an Insurance. Only allowed if associated rental is pending, confirmed, or in_progress.'
    )
    def delete(self, request, insurance_id: int):
        insurance = get_object_or_404(
            Insurance,
            # Filtro posicional primero
            models.Q(car_rent__renter=request.user) | models.Q(parking_rent__renter=request.user),
            # Después, el filtro por pk
            pk=insurance_id
        )
        linked_rental = insurance.car_rent or insurance.parking_rent
        if linked_rental.status not in ['pending', 'confirmed', 'in_progress']:
            return Response(
                {"detail": "No puedes eliminar el seguro de una reserva finalizada o cancelada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        insurance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
