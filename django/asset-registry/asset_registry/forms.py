from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import Asset


class AssetForm(forms.ModelForm):

    class Meta:
        model = Asset
        fields = ('Name','AssetID','Owner','Description','Location','Criticality')
        labels = {
            'Name':'Name',
            'AssetID':'AssetID',
            'Owner':'Owner',
            'Description':'Description',
            'Location':'Location',
            'Criticality':'Criticality'
        }

    def __init__(self, *args, **kwargs):
        super(AssetForm,self).__init__(*args, **kwargs)
        self.fields['Description'].required = False

# Create your forms here.

class NewUserForm(UserCreationForm):
	email = forms.EmailField(required=True)

	class Meta:
		model = User
		fields = ("username", "email", "password1", "password2")

	def save(self, commit=True):
		user = super(NewUserForm, self).save(commit=False)
		user.email = self.cleaned_data['email']
		if commit:
			user.save()
		return user