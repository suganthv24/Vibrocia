from django.db import models
from accounts.models import User

class DailyChallenge(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    xp_reward = models.IntegerField()  # Use IntegerField instead of BigIntegerField
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class ChallengeProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='challenge_progress')
    challenge = models.ForeignKey(DailyChallenge, on_delete=models.CASCADE)
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.challenge.title}"