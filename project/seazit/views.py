#from django.shortcuts import render
from django.http import HttpResponse
from django.shortcuts import render
from django.template import loader
from django.db.models import F, Q
from django.views.generic import TemplateView
from django.core import serializers
from json import dumps
from rest_framework.response import Response
from django.template.response import TemplateResponse

from django.shortcuts import render
from json import dumps
from django.http import JsonResponse
from . import models, serializers
from .models import SeazitWell, AnalysisBmcInput, AnalysisBmcOutput
import pandas as pd
from json import dumps



from django.views.generic import TemplateView


class SeazitTemplateView(TemplateView):
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["active_view_name"] = self.active_view_name
        return context


class Home(SeazitTemplateView):
    template_name = "seazit/home.html"
    active_view_name = "home"

class QC(SeazitTemplateView):
    template_name = "seazit/qc.html"
    active_view_name = "qc"

class Dataset(SeazitTemplateView):
    template_name = "seazit/dataset.html"
    active_view_name = "dataset"

class Resources(SeazitTemplateView):
    template_name = "seazit/resources.html"
    active_view_name = "resources"

class SeazitCR(SeazitTemplateView):
    template_name = "seazit/seazit_cr.html"
    active_view_name = "seazit_cr"


class SeazitBmcByLab(SeazitTemplateView):
    template_name = "seazit/seazit_bmcByLab.html"
    active_view_name = "seazit_bmcByLab"


class SeazitIntegrative(SeazitTemplateView):
    template_name = "seazit/seazit_integrative.html"
    active_view_name = "seazit_integrative"


class Seazitdiver(SeazitTemplateView):
    """SPA shell — serves all 3 React tabs in a single page."""
    template_name = "seazit/seazitdiver.html"
    active_view_name = "seazitdiver"

