from django.contrib import admin

from . import forms


# this is a singleton
site = admin.site

site.login_form = forms.LoginForm
site.site_header = 'SEAZIT-DIVER Administration'
site.site_title = 'SEAZIT-DIVER Admin'
