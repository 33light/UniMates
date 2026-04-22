import os
import uuid

from django.core.files.storage import default_storage
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser])
def upload_file(request):
    """Upload a single file and return its public URL."""
    file = request.FILES.get('file')
    if not file:
        return Response({'detail': 'No file provided.'}, status=status.HTTP_400_BAD_REQUEST)

    folder = request.data.get('folder', 'uploads')
    ext = os.path.splitext(file.name)[1]
    filename = f"{folder}/{uuid.uuid4().hex}{ext}"

    saved_path = default_storage.save(filename, file)
    file_url = request.build_absolute_uri(f'/media/{saved_path}')

    return Response({'url': file_url}, status=status.HTTP_201_CREATED)
