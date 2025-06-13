from django.urls import path
from .views import (
    VerifyRenterAPIView,
    RenterProfileAPIView,
    RegisterCarAPIView, ListCarsAPIView, UpdateDeleteCarAPIView,
    CreateCarAvailabilityAPIView, ListCarAvailabilityAPIView,
    BookCarAPIView, ListOwnCarRentalsAPIView, UpdateCancelCarRentalAPIView,
    RegisterParkingAPIView, ListParkingsAPIView, UpdateDeleteParkingAPIView,
    CreateParkingAvailabilityAPIView, ListParkingAvailabilityAPIView,
    BookParkingAPIView, ListOwnParkingRentalsAPIView, UpdateCancelParkingRentalAPIView,
    PurchaseInsuranceAPIView, ListOwnInsurancesAPIView, UpdateDeleteInsuranceAPIView,
    ListAvailableCarsAPIView,   
    ListAvailableParkingsAPIView 
)

urlpatterns = [
    # Renter
    path('profile/', RenterProfileAPIView.as_view(), name='renter-profile'),
    path('verify_renter/<int:renter_id>/', VerifyRenterAPIView.as_view(), name='verify-renter'),

    # Cars
    path('register_car/', RegisterCarAPIView.as_view(), name='register-car'),
    path('list_cars/', ListCarsAPIView.as_view(), name='list-cars'),
    path('cars/<int:car_id>/', UpdateDeleteCarAPIView.as_view(), name='update-delete-car'),
    path('list_available_cars/', ListAvailableCarsAPIView.as_view(), name='list-available-cars'),  # <-- nuevo

    # Car Availability
    path('create_car_availability/', CreateCarAvailabilityAPIView.as_view(), name='create-car-availability'),
    path('list_car_availability/', ListCarAvailabilityAPIView.as_view(), name='list-car-availability'),

    # Car Rentals
    path('book_car/', BookCarAPIView.as_view(), name='book-car'),
    path('list_car_rentals/', ListOwnCarRentalsAPIView.as_view(), name='list-car-rentals'),
    path('car_rentals/<int:rent_id>/', UpdateCancelCarRentalAPIView.as_view(), name='update-cancel-car-rental'),

    # Parkings
    path('register_parking/', RegisterParkingAPIView.as_view(), name='register-parking'),
    path('list_parkings/', ListParkingsAPIView.as_view(), name='list-parkings'),
    path('parkings/<int:parking_id>/', UpdateDeleteParkingAPIView.as_view(), name='update-delete-parking'),
    path('list_available_parkings/', ListAvailableParkingsAPIView.as_view(), name='list-available-parkings'),  # <-- nuevo

    # Parking Availability
    path('create_parking_availability/', CreateParkingAvailabilityAPIView.as_view(), name='create-parking-availability'),
    path('list_parking_availability/', ListParkingAvailabilityAPIView.as_view(), name='list-parking-availability'),

    # Parking Rentals
    path('book_parking/', BookParkingAPIView.as_view(), name='book-parking'),
    path('list_parking_rentals/', ListOwnParkingRentalsAPIView.as_view(), name='list-parking-rentals'),
    path('parking_rentals/<int:rent_id>/', UpdateCancelParkingRentalAPIView.as_view(), name='update-cancel-parking-rental'),

    # Insurance
    path('purchase_insurance/', PurchaseInsuranceAPIView.as_view(), name='purchase-insurance'),
    path('list_insurances/', ListOwnInsurancesAPIView.as_view(), name='list-insurances'),
    path('insurances/<int:insurance_id>/', UpdateDeleteInsuranceAPIView.as_view(), name='update-delete-insurance'),
]
