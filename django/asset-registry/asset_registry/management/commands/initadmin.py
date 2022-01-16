
from django.conf import settings
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

class Command(BaseCommand):

    def handle(self, *args, **options):
        
        User = get_user_model()
        if User.objects.count() == 0:
            user = settings.ADMIN
            print(user)
            username = user[0].replace(' ', '')
            email = user[1]
            password = user[2].strip()
            print(username, email, password)
            User.objects.create_superuser(username, email, password)
        else:
            print('Admin accounts can only be initialized if no Accounts exist')