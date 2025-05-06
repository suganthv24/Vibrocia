from django import template

register = template.Library()

@register.filter
def select_module(logs, module):
    """Check if a module is completed by the user."""
    for log in logs:
        if log.module.id == module.id and log.completed:
            return True
    return False