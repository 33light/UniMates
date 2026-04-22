from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from system_manager.helper import PageNumberPagination
from .models import Post, PostLike, Comment
from .serializers import PostReadSerializer, PostWriteSerializer, CommentSerializer, CommentWriteSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def post_list_create(request):
    if request.method == 'GET':
        queryset = Post.objects.all().order_by('-created_at')
        # Optional filter: ?author=<firebase_uid> or ?author=<django_uuid>
        author_param = request.GET.get('author')
        if author_param:
            queryset = queryset.filter(author__firebase_uid=author_param)
            if not queryset.exists():
                queryset = Post.objects.filter(author__id=author_param).order_by('-created_at')
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = PostReadSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)

    serializer = PostWriteSerializer(data=request.data)
    if serializer.is_valid():
        post = serializer.save(author=request.user)
        return Response(PostReadSerializer(post, context={'request': request}).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'DELETE'])
@permission_classes([IsAuthenticated])
def post_detail_delete(request, pk):
    try:
        post = Post.objects.get(pk=pk)
    except Post.DoesNotExist:
        return Response({'detail': 'Post not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        return Response(PostReadSerializer(post, context={'request': request}).data)

    if post.author != request.user:
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
    post.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def post_like_toggle(request, pk):
    try:
        post = Post.objects.get(pk=pk)
    except Post.DoesNotExist:
        return Response({'detail': 'Post not found.'}, status=status.HTTP_404_NOT_FOUND)

    like = PostLike.objects.filter(post=post, user=request.user).first()
    if like:
        like.delete()
        post.refresh_from_db()
        return Response({'liked': False, 'likesCount': post.likes_count})
    PostLike.objects.create(post=post, user=request.user)
    post.refresh_from_db()
    return Response({'liked': True, 'likesCount': post.likes_count})


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def comment_list_create(request, pk):
    try:
        post = Post.objects.get(pk=pk)
    except Post.DoesNotExist:
        return Response({'detail': 'Post not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        comments = post.comments_set.all().order_by('created_at')
        return Response(CommentSerializer(comments, many=True, context={'request': request}).data)

    serializer = CommentWriteSerializer(data=request.data)
    if serializer.is_valid():
        comment = serializer.save(post=post, author=request.user)
        return Response(CommentSerializer(comment, context={'request': request}).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
