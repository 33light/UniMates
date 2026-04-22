from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed


class FirebaseAuthentication(BaseAuthentication):
    """
    Verifies Firebase ID tokens sent as:  Authorization: Bearer <token>
    Maps the Firebase UID to a Django User row (get or create).

    In tests, bypass entirely using APIClient.force_authenticate(user=user).
    """

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return None

        token = auth_header.split(' ', 1)[1]

        try:
            import firebase_admin
            from firebase_admin import auth as firebase_auth
            decoded = firebase_auth.verify_id_token(token)
        except ImportError:
            raise AuthenticationFailed('firebase-admin SDK not installed')
        except Exception:
            raise AuthenticationFailed('Invalid Firebase token')

        from users.models import User
        uid = decoded['uid']
        email = decoded.get('email', '')
        # Email/password users have no 'name' claim; fall back to email prefix
        name = decoded.get('name', '') or email.split('@')[0]
        email_prefix = email.split('@')[0]

        user, created = User.objects.get_or_create(
            firebase_uid=uid,
            defaults={'email': email, 'name': name},
        )

        # Back-fill name/username for users created before this fix
        changed = False
        if not user.name:
            user.name = name
            changed = True
        if not user.username:
            # Ensure username is unique by appending digits if needed
            base = email_prefix
            candidate = base
            suffix = 1
            while User.objects.filter(username=candidate).exclude(pk=user.pk).exists():
                candidate = f'{base}{suffix}'
                suffix += 1
            user.username = candidate
            changed = True
        if changed:
            user.save()

        return (user, None)
