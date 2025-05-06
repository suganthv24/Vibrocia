from django.db import models
from accounts.models import User

class Roleplay(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    scenario = models.TextField()
    response = models.TextField()
    score = models.IntegerField(null=True, blank=True)
    feedback = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Roleplay for {self.user.username}"