from django.urls import include, path
from django.views.generic import RedirectView
from rest_framework.routers import DefaultRouter

# Importing views and API views
from . import api, views

# Initialize router
router = DefaultRouter()

# Register API views with the router
router.register("seazit_bmcByLab", api.AnalysisInputKeyViewSet)
router.register("seazit_metadata", api.SeazitProtocolViewSet)
router.register("seazit_sankeydata", api.SeazitOntologyViewSet)
router.register("seazit_result", api.Seazit_readout_resultViewSet)

urlpatterns = [
    # Include the router URLs under the 'api' namespace
    path("api/", include((router.urls, "seazit"), namespace="api")),

    # Legacy redirects for About and Resources — now handled inside the SPA
    path("", RedirectView.as_view(url="/seazit/app/#about", permanent=False), name="home"),
    path("resources/", RedirectView.as_view(url="/seazit/app/#resources", permanent=False), name="resources"),

    # Legacy redirects for Datasets and QC — now handled inside the SPA
    path("dataset/", RedirectView.as_view(url="/seazit/app/#dataset", permanent=False), name="dataset"),
    path("quality-control/", RedirectView.as_view(url="/seazit/app/#quality-control", permanent=False), name="qc"),

    # SPA shell — serves all 3 React tabs (Concentration Response, BMC by Dataset, Integrative Analyses)
    path("app/", views.Seazitdiver.as_view(), name="seazitdiver"),

    # Legacy redirects — keep old URLs working (bookmarks, external links)
    path("seazit_cr/", RedirectView.as_view(url="/seazit/app/#seazit_cr", permanent=False), name="seazit_cr"),
    path("seazit_bmcByLab/", RedirectView.as_view(url="/seazit/app/#seazit_bmcByLab", permanent=False), name="seazit_bmcByLab"),
    path("seazit_integrative/", RedirectView.as_view(url="/seazit/app/#seazit_integrative", permanent=False), name="seazit_integrative"),
]
