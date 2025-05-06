from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    email = models.EmailField(unique=True)
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    xp = models.IntegerField(default=0)
    level = models.IntegerField(default=1)

    def __str__(self):
        return self.username