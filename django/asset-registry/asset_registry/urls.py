from django.urls import path,include
from . import views

urlpatterns = [
    path('assets', views.assets_list,name='assets_list'), # get and post req. for insert operation
    path('assets/<int:AssetID>/', views.asset_form,name='asset_update'), # get and post req. for update operation
    path('assets/delete/<int:AssetID>/',views.asset_delete,name='asset_delete'),
    path('assets/new/',views.asset_form,name='asset_insert'), # get req. to retrieve and display all records
    path('assets/search_assets/',views.search_assets,name='search_assets'),
    path('',views.assets_home,name='assets_home'),
    path('pdf', views.generatePDF,name='report'),
    path('pdf_search', views.search_assets_pdf,name='report_search'),
    path("register", views.register_request, name="register"),
    path("login", views.login_request, name="login"),
    path("logout", views.logout_request, name= "logout"),
    path("healthz", views.health, name= "health")
]