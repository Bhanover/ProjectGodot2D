# Generated by Django 4.2.7 on 2023-12-07 12:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('godotapp', '0002_alter_estadisticasjuego_vidas_actuales'),
    ]

    operations = [
        migrations.AddField(
            model_name='estadisticasjuego',
            name='oro_total_recolectado',
            field=models.IntegerField(default=0),
        ),
    ]
