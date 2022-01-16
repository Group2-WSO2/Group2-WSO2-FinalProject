# Create your views here.
from django.shortcuts import render, redirect
from django.db.models.query_utils import Q
from .forms import AssetForm, NewUserForm
from .models import Asset
from django.contrib.auth import login, authenticate, logout
from django.contrib import messages
from .utils import render_to_pdf
from django.contrib.auth.forms import AuthenticationForm
from django.conf import settings
from django.core.cache.backends.base import DEFAULT_TIMEOUT
from django.core.cache import cache
from django.views.decorators.cache import cache_page
#import os
from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
import logging
logger = logging.getLogger(__name__)
CACHE_TTL = getattr(settings, 'CACHE_TTL', DEFAULT_TIMEOUT)
search_pdf=""

def register_request(request):
	if request.method == "POST":
		form = NewUserForm(request.POST)
		if form.is_valid():
			user = form.save()
			login(request, user)
			messages.success(request, "Registration successful." )
			return redirect("/")
		messages.error(request, "Unsuccessful registration. Invalid information.")
	form = NewUserForm()
	return render (request=request, template_name="asset_registry/register.html", context={"register_form":form})


def login_request(request):
	if request.method == "POST":
		form = AuthenticationForm(request, data=request.POST)
		if form.is_valid():
			username = form.cleaned_data.get('username')
			password = form.cleaned_data.get('password')
			user = authenticate(username=username, password=password)
			if user is not None:
				login(request, user)
				messages.info(request, f"You are now logged in as {username}.")
				return redirect("/")
			else:
				messages.error(request,"Invalid username or password.")
		else:
			messages.error(request,"Invalid username or password.")
	form = AuthenticationForm()
	return render(request=request, template_name="asset_registry/login.html", context={"login_form":form})

@cache_page(CACHE_TTL)
@login_required(login_url='/login')
def logout_request(request):
	logout(request)
	messages.info(request, "You have successfully logged out.") 
	return redirect("/login")

@cache_page(CACHE_TTL)
@login_required(login_url='/login')
def generatePDF(request):
    context = {'pdf_list': Asset.objects.all()}
    pdf = render_to_pdf('asset_registry/pdf_all.html', context)
    if pdf:
        response = HttpResponse(pdf, content_type='application/pdf')
        filename = "all-assets.pdf"
        content = "inline; filename='%s'" %(filename)
        download = request.GET.get("download")
        if download:
            content = "attachment; filename='%s'" %(filename)
        response['Content-Disposition'] = content
        return response
    return HttpResponse("Not found")
    #return HttpResponse(pdf, content_type='application/pdf')


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def assets_list(request):
    context = {'assets_list': Asset.objects.all()}
    return render(request, "asset_registry/assets_list.html", context)


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def assets_home(request):
    context = {'assets_home': Asset.objects.all()}
    return render(request, "asset_registry/assets_home.html", context)


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def asset_form(request, AssetID=0):
    if request.method == "GET":
        if int(AssetID) == 0:
            form = AssetForm()
        else:
            asset = Asset.objects.get(pk=AssetID)
            form = AssetForm(instance=asset)
        return render(request, "asset_registry/asset_form.html", {'form': form})
    else:
        print(type(AssetID))
        print(AssetID)
        if AssetID == 0:
            form = AssetForm(request.POST)
        else:
            asset = Asset.objects.get(pk=AssetID)
            form = AssetForm(request.POST,instance= asset)
        if form.is_valid():
            form.save()
        return redirect('/')


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def asset_delete(request,AssetID):
    asset = Asset.objects.get(pk=AssetID)
    asset.delete()
    return redirect('/assets')


@login_required(login_url='/login')
def search_assets(request):
    global search_pdf
    search_pdf=""
    if request.method == "POST":
        searched = request.POST['searched']
        search_pdf=searched
        if cache.get(searched):
            assets = cache.get(searched)
            logger.info('Retrieve data from the CACHE')
        else:
            assets = Asset.objects.filter(Q(Name__contains=searched) | Q(AssetID__contains=searched))
            cache.set(searched,assets,15)
            logger.info('Retrieve data from the Database')
        return render(request, "asset_registry/search.html",{'searched': searched, 'assets': assets})
    else:
        return render(request, "asset_registry/search.html",{})


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def search_assets_pdf(request):
    global search_pdf
    searched = search_pdf
    context = {'pdf_list': Asset.objects.filter(Q(Name__contains=searched) | Q(AssetID__contains=searched)),'searched':searched}
    pdf = render_to_pdf('asset_registry/pdf_search.html', context)
    if pdf:
        response = HttpResponse(pdf, content_type='application/pdf')
        filename = "searched-assets-for-{}.pdf".format(str(searched))
        content = "inline; filename='%s'" %(filename)
        download = request.GET.get("download")
        if download:
            content = "attachment; filename='%s'" %(filename)
        response['Content-Disposition'] = content
        return response
    return HttpResponse("Not found")
    return HttpResponse(pdf, content_type='application/pdf')


@login_required(login_url='/login')
@cache_page(CACHE_TTL)
def homepage(request):
    return render(request, "asset_registry/home.html", {})

def health(request):
    return render(request, "asset_registry/health.html", {})