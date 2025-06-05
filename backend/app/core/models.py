"""
Database models
"""
from django.conf import settings
from django.db import models
from django.contrib.auth import get_user_model
import django.contrib.auth as DjangoAuth
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
)

from django.contrib.auth.password_validation import validate_password
from django.utils import timezone



class Region(models.Model):
    name = models.CharField(max_length=250)
    description = models.CharField(max_length=250)

    def __str__(self):
        return self.name

class UserManager(BaseUserManager):
    """Manager for users."""

    def create_superuser(self, email, password):
        """Create and return a new superuser."""
        user = self.create_user(email, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user

    def create_user(self, email, password, **extra_fields):
        """Create, save, and return a new user."""
        user = self.model(email=self.normalize_email(email), **extra_fields)
        validate_password(password)
        user.set_password(password)
        user.save(using=self._db)
        return user


    @classmethod
    def createSuperInstance(cls):
        data = {
            'email': 'admin@example.com',
            'password': 'admin',
        }
        admin = get_user_model().objects.filter(email=data['email']).first()
        if admin:
            print("Admin instance already created")
            return

        get_user_model().objects.create_superuser(**data)
        print("Admin instance created")


class User(AbstractBaseUser):
    """User in the system."""

    email = models.EmailField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    region = models.ForeignKey(Region, on_delete=models.RESTRICT, blank=True, null=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)  
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'

    def __str__(self):
        return "User :"+self.email

