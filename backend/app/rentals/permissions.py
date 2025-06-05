# rentals/permissions.py

from rest_framework import permissions
from django.utils import timezone

class IsVerifiedRenter(permissions.BasePermission):
    """
    Permiso que solo permite acciones a usuarios con perfil Renter verificado.
    - El request.user debe estar autenticado.
    - El request.user debe tener un perfil Renter asociado (OneToOne).
    - El perfil Renter debe tener is_verified == True.
    """

    message = "El usuario debe ser un Renter verificado para realizar esta acción."

    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False

        # Intentamos acceder al perfil Renter. Si no existe, no es Renter.
        try:
            renter_profile = user.renter_profile
        except Exception:
            return False

        return renter_profile.is_verified


class IsOwnerOfCar(permissions.BasePermission):
    """
    Permiso que verifica que el(request.user) sea el dueño (owner) del Car.
    Se asume que la vista proporciona 'pk' o 'car_pk' para obtener instancia de Car.
    """

    message = "Solo el propietario del vehículo puede realizar esta acción sobre el Car."

    def has_object_permission(self, request, view, obj):
        # obj es instancia de Car
        # Verificamos que el usuario actual corresponda al owner.user
        return request.user.is_authenticated and hasattr(request.user, 'renter_profile') and obj.owner == request.user.renter_profile


class IsOwnerOfParking(permissions.BasePermission):
    """
    Permiso que verifica que el(request.user) sea el dueño (owner) del Parking.
    Se asume que la vista proporciona 'pk' o 'parking_pk' para obtener instancia de Parking.
    """

    message = "Solo el propietario del estacionamiento puede realizar esta acción sobre el Parking."

    def has_object_permission(self, request, view, obj):
        # obj es instancia de Parking
        return request.user.is_authenticated and hasattr(request.user, 'renter_profile') and obj.owner == request.user.renter_profile


class IsOwnerOfCarRentOrReadOnly(permissions.BasePermission):
    """
    Permiso que:
      - Permite lectura (GET, HEAD, OPTIONS) para cualquier usuario autenticado.
      - Solo el "renter" que creó el CarRent puede modificarlo (PUT, PATCH, DELETE).
      - Además, para crear un CarRent se requiere que el usuario esté verificado (podría combinarse con IsVerifiedRenter).
    """

    message = "Solo el cliente que reservó este vehículo puede modificar o cancelar la reserva."

    def has_permission(self, request, view):
        # Si es creación (POST), validamos que sea Renter verificado
        if request.method == 'POST':
            try:
                renter_profile = request.user.renter_profile
            except Exception:
                return False
            return renter_profile.is_verified
        # Para otros métodos, permitimos continuar y delegar a has_object_permission
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        # obj es instancia de CarRent
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.renter == request.user


class IsOwnerOfParkingRentOrReadOnly(permissions.BasePermission):
    """
    Permiso que:
      - Permite lectura para cualquier usuario autenticado.
      - Solo el "renter" que creó el ParkingRent puede modificarlo.
      - Para crear un ParkingRent se requiere que el usuario esté verificado (podría combinarse con IsVerifiedRenter).
    """

    message = "Solo el cliente que reservó este estacionamiento puede modificar o cancelar la reserva."

    def has_permission(self, request, view):
        if request.method == 'POST':
            try:
                renter_profile = request.user.renter_profile
            except Exception:
                return False
            return renter_profile.is_verified
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        # obj es instancia de ParkingRent
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.renter == request.user


class IsOwnerOfInsuranceOrReadOnly(permissions.BasePermission):
    """
    Permiso que:
      - Permite lectura para cualquier usuario autenticado.
      - Solo el dueño de la reserva (CarRent o ParkingRent) asociada 
        al Insurance puede modificar o eliminar la póliza.
    """

    message = "Solo el propietario de la reserva vinculada puede modificar esta póliza de seguro."

    def has_permission(self, request, view):
        # Para listar (GET, HEAD, OPTIONS) basta con que esté autenticado:
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated

        # Para crear (POST), suponemos que se crea junto a una reserva ya existente.
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        # obj es instancia de Insurance
        # Permitimos lectura
        if request.method in permissions.SAFE_METHODS:
            return True

        # Para modificar/eliminar, el usuario debe ser el Renter asociado
        # Verificamos si está asociado a CarRent o ParkingRent
        if obj.car_rent:
            owner = obj.car_rent.renter
        else:
            owner = obj.parking_rent.renter

        return request.user == owner
