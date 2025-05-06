from django.contrib import admin
from .models import Survey, SurveyResponse

@admin.register(Survey)
class SurveyAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'created_at')
    list_filter = ('created_at', 'user')
    search_fields = ('title',)
    readonly_fields = ('created_at', 'updated_at')

@admin.register(SurveyResponse)
class SurveyResponseAdmin(admin.ModelAdmin):
    list_display = ('survey', 'user', 'submitted_at')
    list_filter = ('submitted_at', 'user')
    search_fields = ('survey__title',)
    readonly_fields = ('submitted_at',)