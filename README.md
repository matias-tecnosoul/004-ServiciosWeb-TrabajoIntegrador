# 004-ServiciosWeb-EntregaFinal
Instalar redmine en su última versión disponible estable. La instalación del producto debe considerar todo el trabajo en una virtual, contemplando los siguiente puntos:

No usar la versión de ruby provista por el Sistema Operativo, sino instalar la versión de ruby sugerida más nueva usando algún mecanismo que permita instalar ruby como rbenv, rvm o asdf (como se explica en la documentación)
Usar un usuario diferente de root para correr redmine
Integrar el application server de ruby con algún web server eficiente en forma de proxy reverso de tal forma que el contenido estático lo sirva el web server y no ruby.
Este punto es importante respetarlo como se expresa en esta configuración
Instalar alguna base de datos soportada por el producto y configurarla en la misma máquina donde correrá redmine, considerando que en un futuro, la misma podría moverse a otros servidor
La virtual deberá reiniciarse y mantener el servicio funcional.
La entrega consta de mostrar al instructor la máquina virtual con redmine corriendo y recorrer las diferentes configuraciones realizadas.

