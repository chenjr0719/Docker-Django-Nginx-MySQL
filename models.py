from django.db import models

# Create your models here.

class Model_example(models.Model):
    id = models.AutoField(primary_key=True)
    subject = models.CharField(max_length=100)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.subject
