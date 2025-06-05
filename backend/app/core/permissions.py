from rest_framework import permissions

safe_methods = ("GET", "OPTIONS", "HEAD")

class IsLogged(permissions.IsAuthenticated):
    def has_permission(self, request, view):
        authenticated = super().has_permission(request, view)
        if not authenticated:
            return False
        user = request.user

        # if not Session.is_logged(user):
        #     return False 
        return True

class IsAdmin(permissions.IsAuthenticated):
    def has_permission(self, request, view):
        authenticated = super().has_permission(request, view)
        if not authenticated: 
            return False
        user = request.user

        if not user.is_staff:
            return False
        return True

class IsAdminOrReadOnly(permissions.IsAuthenticated):
    def has_permission(self, request, view):
        admin_permsion = IsAdmin().has_permission(request=request, view=view)
        read_permission = request.method in safe_methods
        return admin_permsion or read_permission
    
