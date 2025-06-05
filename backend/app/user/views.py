from drf_spectacular.utils import (
    extend_schema,
    extend_schema_view,
    OpenApiParameter,
    OpenApiExample
)
from drf_spectacular.types import OpenApiTypes
from rest_framework import generics, views, permissions, exceptions, authentication
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.settings import api_settings
from rest_framework import pagination
from rest_framework import status
from rest_framework.viewsets import ModelViewSet

from django.contrib.auth.models import AnonymousUser
from core.permissions import IsLogged
from core.utils import LogInThrottle

from django.contrib.auth import get_user_model, logout, login

from user.serializers import (
    RegionSerializer,
    AuthTokenSerializer,
    UserSerializer,
    ManageUserSerializer,
    HealthCheckSerializer,
)

from core.models import Region

from user.filters import UserFilter

from django.utils import timezone
from django.shortcuts import get_object_or_404

class UserListPagination(pagination.CursorPagination):
    page_size = 10
    ordering = 'email'
    cursor_query_param = 'cursor'
    page_size_query_param = 'page_size'
    max_page_size = 100

    def get_paginated_response(self, data):
        return super().get_paginated_response(data)

class LogListPagination(pagination.CursorPagination):
    ordering = 'login_time'
    cursor_query_param = 'cursor'
    page_size_query_param = 'page_size'
    max_page_size = 100

    def get_paginated_response(self, data):
        return super().get_paginated_response(data)

@extend_schema_view(
    get=extend_schema(
        tags=['Users'],
        summary='List users',
        description='Retrieve paginated list of users filtered by role',
        parameters=[
            OpenApiParameter(
                name='rol',
                type=OpenApiTypes.STR,
                location=OpenApiParameter.QUERY,
                description='Filter users by role',
                examples=[
                    OpenApiExample(
                        'Admin role filter',
                        value='admin',
                        description='Filter users with admin role'
                    ),
                    OpenApiExample(
                        'User role filter',
                        value='user',
                        description='Filter regular users'
                    )
                ]
            ),
            OpenApiParameter(
                name='page_size',
                type=OpenApiTypes.INT,
                location=OpenApiParameter.QUERY,
                description='Number of results per page (max 100)'
            ),
            OpenApiParameter(
                name='cursor',
                type=OpenApiTypes.STR,
                location=OpenApiParameter.QUERY,
                description='Pagination cursor'
            )
        ]
    )
)
class ListUsersView(generics.ListAPIView):
    """List shows users in the api"""
    serializer_class = UserSerializer
    queryset = get_user_model().objects.all().order_by('email')
    filterset_class = UserFilter
    pagination_class = UserListPagination

    def get_queryset(self):
        return get_user_model().objects.all()

@extend_schema(
    tags=['Authentication'],
    summary='User login',
    description='Authenticate user and return API token with user details',
    request=AuthTokenSerializer,
    examples=[
        OpenApiExample(
            'Successful Login',
            value={
                'email': 'user@example.com',
                'password': 'securepassword123'
            },
            response_only=True,
            status_codes=['200']
        )
    ],
    responses={
        200: UserSerializer,
        401: OpenApiTypes.OBJECT,
        404: OpenApiTypes.OBJECT
    }
)
class CreateTokenView(ObtainAuthToken):
    """Create a new auth token for user."""
    serializer_class = AuthTokenSerializer
    renderer_classes = api_settings.DEFAULT_RENDERER_CLASSES

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data.get('user')
        if not user:
            return Response({'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        if isinstance(user, AnonymousUser):
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        login(request=request, user=user)
        response_serializer = UserSerializer(instance=user)
        data = response_serializer.data
        token, created = Token.objects.get_or_create(user=user)
        data['token'] = token.key
        return Response(data=data, status=status.HTTP_200_OK)

@extend_schema(
    tags=['Authentication'],
    summary='User logout',
    description='Invalidate current authentication token and log out user',
    request=None,
    responses={
        202: None,
        412: OpenApiTypes.OBJECT
    }
)
class LogoutView(views.APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        if isinstance(request.user, AnonymousUser):
            return Response(
                {'error': 'No authenticated user'}, 
                status=status.HTTP_412_PRECONDITION_FAILED
            )
        logout(request=request)
        return Response(status=status.HTTP_202_ACCEPTED)

@extend_schema(
    tags=['Users'],
    summary='User profile',
    description='Retrieve and update authenticated user profile',
    responses=UserSerializer,
    methods=['GET', 'PATCH']
)
class UserProfileView(generics.RetrieveUpdateAPIView):
    """Manage the authenticated user."""
    authentication_classes = [authentication.TokenAuthentication]
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'patch']

    def get_object(self):
        return self.request.user

@extend_schema(
    tags=['Users'],
    summary='Manage user',
    description='Admin endpoint to manage user profiles (by email)',
    request=ManageUserSerializer,
    responses=ManageUserSerializer,
    parameters=[
        OpenApiParameter(
            name='email',
            type=OpenApiTypes.EMAIL,
            location=OpenApiParameter.QUERY,
            required=True,
            description='Email address of user to manage',
            examples=[
                OpenApiExample(
                    'Example Email',
                    value='admin@example.com'
                )
            ]
        )
    ]
)
class ManageUserView(generics.RetrieveUpdateAPIView):
    """Edit user profiles"""
    serializer_class = ManageUserSerializer

    def get_object(self):
        body_data = UserSerializer(self.request.data).data
        email = body_data.get('email', None)
        if not email:
            raise MissingQueryParameterException(detail="Missing email parameter")
        return get_object_or_404(get_user_model(), email=email)

@extend_schema(
    tags=['Users'],
    summary='Create user',
    description='Create new user account',
    request=UserSerializer,
    responses=UserSerializer,
    examples=[
        OpenApiExample(
            'Create User Example',
            value={
                'email': 'newuser@example.com',
                'password': 'securepassword123',
                'name': 'New User'
            }
        )
    ]
)
class CreateUserView(generics.CreateAPIView):
    """Create user profiles"""
    serializer_class = UserSerializer

#
@extend_schema_view(
    list=extend_schema(
        tags=['Regions'],
        summary='List regions',
        description='Get paginated list of all available regions',
        parameters=[
            OpenApiParameter(
                name='ordering',
                type=OpenApiTypes.STR,
                location=OpenApiParameter.QUERY,
                description='Field to sort results by'
            )
        ]
    ),
    create=extend_schema(
        tags=['Regions'],
        summary='Create region',
        description='Create new region entry',
        request=RegionSerializer,
        responses=RegionSerializer
    ),
    retrieve=extend_schema(
        tags=['Regions'],
        summary='Get region',
        description='Retrieve specific region details',
        responses=RegionSerializer
    ),
    update=extend_schema(
        tags=['Regions'],
        summary='Update region',
        description='Full update of region details',
        request=RegionSerializer,
        responses=RegionSerializer
    ),
    partial_update=extend_schema(
        tags=['Regions'],
        summary='Partial update region',
        description='Partial update of region details',
        request=RegionSerializer,
        responses=RegionSerializer
    ),
    destroy=extend_schema(
        tags=['Regions'],
        summary='Delete region',
        description='Permanently remove region',
        responses=None
    )
)
class RegionView(ModelViewSet):
    queryset = Region.objects.all()
    serializer_class = RegionSerializer
    authentication_classes = []
    permission_classes = []

@extend_schema(
    tags=['System'],
    summary='Health check',
    description='Verify API service availability',
    responses=HealthCheckSerializer,
    methods=['GET']
)
class HealthCheck(views.APIView):
    def get(self, request, *args, **kargs):
        return Response({'status': 'OK'}, status=status.HTTP_200_OK)

class MissingQueryParameterException(exceptions.APIException):
    status_code = 400
    default_detail = 'Missing required query parameter'
    default_code = 'missing_query_parameter'