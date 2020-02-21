DATABASES = {
    'default': {
        'ATOMIC_REQUESTS': True,
        'ENGINE': 'awx.main.db.profiled_pg',
        'NAME': {{ include "awx-db-name" . | squote }},
        'USER': {{ include "awx-db-user" . | squote }},
        'PASSWORD': {{ include "awx-db-password" . | squote }},
        'HOST': {{ include "awx-db-host" . | squote }},
        'PORT': {{ include "awx-db-port" . | squote }},
    }
}
BROKER_URL = 'amqp://{}:{}@{}:{}/{}'.format(
    "{{ .Values.rabbitmq.rabbitmq.username }}",
    "{{ .Values.rabbitmq.rabbitmq.password }}",
    "{{ .Release.Name }}-rabbitmq",
    "{{ .Values.rabbitmq.service.port }}",
    "awx")
CHANNEL_LAYERS = {
    'default': {'BACKEND': 'asgi_amqp.AMQPChannelLayer',
                'ROUTING': 'awx.main.routing.channel_routing',
                'CONFIG': {'url': BROKER_URL}}
}
