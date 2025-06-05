"""
URL mapping for the user API.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from user import views

app_name = 'user'

router = DefaultRouter()
router.register(r'region', views.RegionView, basename='region')

urlpatterns = [
    path('list/', views.ListUsersView.as_view(), name = 'list'),
    path('manage/', views.ManageUserView.as_view(), name='manage'),
    path('login/', views.CreateTokenView.as_view(), name='token'),
    path('me/', views.UserProfileView.as_view(), name = 'me'),
    path('logout/', views.LogoutView.as_view(), name = 'logout'),
    path('create/', views.CreateUserView.as_view(), name = 'create'),
    path('region/', include(router.urls)),
]