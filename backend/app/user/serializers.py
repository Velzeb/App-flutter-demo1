"""
Serializers for the user API view.
"""
from django.contrib.auth import (
    get_user_model,
    authenticate,
)
from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext as _
from rest_framework import serializers

from rest_framework.exceptions import APIException
from django.contrib.auth.models import AnonymousUser

from core.models import Region

Player = get_user_model()

class NotValidRole(APIException):
    status_code = 400
    default_detail = 'Ingrese un rol válido'
    default_code = 'role_field'


class RegionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Region
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the user object."""

    class Meta:
        model = Player
        fields = ['pk', 'email', 'password', 'name', 'phone_number', 'is_active', 'is_staff', 'region'] 
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def create(self, validated_data):
        player = Player.objects.create(**validated_data)
        validate_password(player)
        player.set_password(validated_data['password'])
        player.save()
        return player

    def update(self, instance, validated_data):
        """Update and return user."""
        password = validated_data.pop('password', None)
        user = super().update(instance, validated_data)

        if password:
            user.set_password(password)
            user.save()

        return user


class ManageUserSerializer(UserSerializer):

    class Meta:
        model = Player
        fields = ['email', 'password', 'name', 'phone_number', 'is_active']  # Added 'phone_number'
        extra_kwargs = {'password': {'write_only': True, 'min_length': 12}}


    def create(self, validated_data):
        """Create and return a user with encrypted password."""
        return get_user_model().objects.create_user(**validated_data)

    def update(self, instance, validated_data):
        """Update and return user."""
        return super().update(instance, validated_data)


class AuthTokenSerializer(serializers.Serializer):
    """Serializer for the user auth token."""
    email = serializers.EmailField()
    password = serializers.CharField(
        style={'input_type': 'password'},
        trim_whitespace=False,
    )

    def validate(self, attrs):
        """Validate and authenticate the user."""
        email = attrs.get('email')
        password = attrs.get('password')

        user = get_user_model().objects.filter(email=email)

        if not user.exists():
            attrs['user'] = AnonymousUser()
            return attrs

        user = authenticate(
            request=self.context['request'],
            username=email,
            password=password,
        )

        if not user:
            return attrs

        attrs['user'] = user
        return attrs

class HealthCheckSerializer(serializers.Serializer):
    status = serializers.CharField()
