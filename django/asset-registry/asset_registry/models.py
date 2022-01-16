from django.db import models

# Create your models here.
class Asset(models.Model):
    Name = models.CharField(max_length=200)
    AssetID = models.IntegerField(primary_key=True)
    Owner= models.CharField(max_length=200)
    Description= models.CharField(max_length=200)
    Location= models.CharField(max_length=100)
    Criticality = models.CharField(
        max_length=1,
        default='M',
        choices= [
            ('C', 'Critical'),
            ('M', 'Medium'),
            ('L', 'Low'),
        ])
    class Meta:
       unique_together = ("Name", "AssetID","Owner","Description","Location","Criticality")