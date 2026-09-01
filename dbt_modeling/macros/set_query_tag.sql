{% macro set_query_tag() %}
    {% if execute and model %}
        alter session set query_tag = '{{ model.name }}';
    {% endif %}
{% endmacro %}