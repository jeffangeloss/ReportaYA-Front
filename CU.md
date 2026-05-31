Revision de CU de ReportaYA-Front.

## CU-01: Iniciar sesión:
### Descripción:
    Permitir que un usuario autenticado acceda a la aplicación ingresando sus credenciales y sea dirigido a la vista correspondiente a su rol.
### Actores:
    Ciudadano, Operador de Oficina Municipal, Técnico de Campo Municipal.
### Precondiciones:
    El usuario debe tener una cuenta registrada en el sistema. Debe tener internet para acceder a la aplicación.
### Flujo principal:
1. El usuario abre la aplicación ReportaYA-Front.
2. El usuario esta en la vista 01 Login.
3. El usuario ingresa su Usuario y Contraseña.
4. El usuario hace click en el botón "Iniciar sesión".
5. El backend verifica las credenciales ingresadas.
6. Si las credenciales son correctas, el backend devuelve un token de autenticación y la información del usuario.
7. El frontend almacena el token de autenticación y la información del usuario.
8. El frontend redirige al usuario a la vista correspondiente a su rol [Ciudadano-> 02 Inicio, Operador de Oficina Municipal-> 01 Cola de reportes, Técnico de Campo Municipal-> 01 Mis asignaciones].
### Flujo alternativos:
#### Escenario 1: Credenciales incorrectas
1. El usuario ingresa un Usuario o Contraseña incorrectos.
2. El backend devuelve un mensaje de error indicando que las credenciales son incorrectas.
3. El frontend muestra el mensaje de error al usuario, indicando que las credenciales son incorrectas y solicitando que intente nuevamente.
#### Escenario 2: Usuario no registrado
1. El usuario ingresa un Usuario que no está registrado en el sistema.
2. El backend devuelve un mensaje de error indicando que el usuario no está registrado.
3. El frontend muestra el mensaje de error al usuario, indicando que el usuario no está registrado y solicitando que se registre.
### Postcondiciones:
    El usuario ha iniciado sesión exitosamente y ha sido redirigido a la vista correspondiente a su rol, o ha recibido un mensaje de error indicando que las credenciales son incorrectas o que el usuario no está registrado.
### Requisitos no funcionales:
- El sistema debe garantizar la seguridad de las credenciales del usuario durante el proceso de autenticación
- El sistema debe manejar adecuadamente los errores de autenticación y proporcionar mensajes claros al usuario.
- El sistema debe ser capaz de manejar múltiples intentos de inicio de sesión sin comprometer la seguridad.
- El sistema debe redirigir al usuario a la vista correspondiente a su rol de manera rápida y eficiente después de un inicio de sesión exitoso. 

## CU-02: Registrarse:
### Descripción:
    Permitir que un ciudadano cree una cuenta proporcionando sus datos y reciba un correo de confirmación para activar su perfil.
### Actor: 
    Ciudadano.
### Precondiciones:
    El usuario debe tener acceso a internet , ser una persona física, ser mayor de edad y no tener una cuenta registrada en el sistema.
### Flujo principal:
1. El usuario abre la aplicación ReportaYA-Front.
2. El usuario está en la vista 01 Login.
3. El usuario hace click en el botón "Registrarse".
4. El frontend redirige al usuario a la vista 07 Registro.
5. El usuario ingresa: Nombre, Apellido, Dni , Telefono, Correo electrónico, Usuario y Contraseña.
6. El usuario hace click en el botón "Registrarse".
7. El backend verifica los datos ingresados.
8. Si los datos son válidos, el backend crea una nueva cuenta de usuario.
9. El frontend muestra un mensaje de éxito indicando que la cuenta ha sido creada correctamente.
### Flujo alternativo:
#### Escenario 1: Datos inválidos
1. El usuario ingresa datos inválidos o incompletos.
2. El backend devuelve un mensaje de error indicando que los datos son inválidos.
3. El frontend muestra el mensaje de error al usuario, indicando que los datos son inválidos y solicitando que intente nuevamente.
#### Escenario 2: Usuario ya registrado
1. El usuario ingresa un Usuario o Correo electrónico que ya está registrado en el sistema.
2. El backend devuelve un mensaje de error indicando que el Usuario o Correo electrónico ya está registrado.
3. El frontend muestra el mensaje de error al usuario, indicando que el Usuario o Correo electrónico ya está registrado y solicitando que intente con otro Usuario o Correo electrónico.   
### Postcondiciones:
    El usuario ha creado una cuenta exitosamente y puede iniciar sesión con sus nuevas credenciales.
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos personales del usuario durante el proceso de registro
- El sistema debe manejar adecuadamente los errores de registro y proporcionar mensajes claros al usuario.
- El sistema debe ser capaz de validar los datos ingresados por el usuario antes de crear la cuenta.

## CU-03: Recuperar contraseña:
### Descripción:
    Permitir que un usuario recupere su contraseña mediante un proceso de verificación de identidad y restablecimiento de contraseña.   
### Actor:
    Ciudadano, Operador de Oficina Municipal, Técnico de Campo Municipal.
### Precondiciones:
    El usuario debe tener una cuenta registrada en el sistema y acceso a su correo electrónico asociado a la cuenta.
### Flujo principal:
1. El usuario abre la aplicación ReportaYA-Front.
2. El usuario está en la vista 01 Login.
3. El usuario hace click en el enlace "¿Olvidaste tu contraseña?".
4. El frontend redirige al usuario a la vista 08 Recuperar contraseña.  
5. El usuario ingresa su correo electrónico asociado a la cuenta.
6. El usuario hace click en el botón "Enviar".
7. El backend verifica si el correo electrónico está asociado a una cuenta registrada.  
8. Si el correo electrónico está asociado a una cuenta, el backend envía un correo electrónico al usuario con un enlace para restablecer su contraseña.
9. El usuario recibe el correo electrónico y hace click en el enlace para restablecer su contraseña.
10. El frontend redirige al usuario a la vista 09 Restablecer contraseña.
11. El usuario ingresa una nueva contraseña y confirma la nueva contraseña.
12. El usuario hace click en el botón "Restablecer contraseña".
13. El backend verifica que las contraseñas ingresadas coincidan y actualiza la contraseña de la cuenta del usuario.
14. El frontend muestra un mensaje de éxito indicando que la contraseña ha sido restablecida correctamente
### Flujo alternativo:
#### Escenario 1: Correo electrónico no asociado a una cuenta  
1. El usuario ingresa un correo electrónico que no está asociado a ninguna cuenta registrada en el sistema.
2. El backend devuelve un mensaje de error indicando que el correo electrónico no está asociado a ninguna cuenta.
3. El frontend muestra el mensaje de error al usuario, indicando que el correo electrónico no está asociado a ninguna cuenta y solicitando que intente nuevamente con otro correo electrónico.  
#### Escenario 2: Contraseñas no coinciden  
1. El usuario ingresa una nueva contraseña y una confirmación de contraseña que no coinciden.
2. El backend devuelve un mensaje de error indicando que las contraseñas no coinciden.  
3. El frontend muestra el mensaje de error al usuario, indicando que las contraseñas no coinciden y solicitando que ingrese contraseñas que coincidan.  
### Postcondiciones:
    El usuario ha restablecido su contraseña exitosamente y puede iniciar sesión con su nueva contraseña.
### Requisitos no funcionales:
- El sistema debe garantizar la seguridad del proceso de recuperación de contraseña para evitar accesos no autorizados a las cuentas de los usuarios.
- El sistema debe manejar adecuadamente los errores durante el proceso de recuperación de contraseña y proporcionar mensajes claros al usuario.
- El sistema debe ser capaz de enviar correos electrónicos de manera confiable para el proceso de recuperación de contraseña.   

## CU-04: Reportar incidencia urbana:
### Descripción:
    Permitir que un ciudadano cree y envíe un nuevo reporte de incidente urbano, aportando ubicación, tipo de problema, descripción y evidencia multimedia, y posteriormente poder hacerle seguimiento.
### Actor:
    Ciudadano.
### Precondiciones:
    El usuario debe haber iniciado sesión en la aplicación y tener acceso a internet.

### Flujo principal:
1. El usuario se encuentra en la vista 02 Inicio.
2. El usuario hace click en el botón "Reportar incidencia".
3. El frontend redirige al usuario a la vista 04 Reportar.
4. El usuario ingresa el título del reporte , la descripción y selecciona el tipo de problema [Infrastructura, Residuos, Seguridad, Alumbrado, Otro].
5. El usuario selecciona la ubicación del incidente en un mapa interactivo.
6. El usuario adjunta fotos del incidente(max 5 fotos).
7. El usuario hace click en el botón "Enviar reporte".
8. El backend recibe los datos del reporte, los valida , crea un nuevo reporte en el sistema , asigna el estado de reporte como "Pendiente" y envia las fotos al servicio de Firebase.
9. El frontend muestra un mensaje de éxito indicando que el reporte ha sido enviado correctamente y redirige al usuario a la vista 03 Mis reportes.
10. El usuario puede ver el reporte recién creado en la vista 03 Mis reportes (y también en el listado de reportes recientes de la vista 02 Inicio) y hacerle seguimiento a su estado.
### Flujo alternativo:
#### Escenario 1: Datos inválidos
1. El usuario ingresa datos inválidos o incompletos en el formulario de reporte.
2. El usuario hace click en el botón "Enviar reporte".
3. El backend devuelve un mensaje de error indicando que los datos son inválidos.   
4. El frontend muestra el mensaje de error al usuario, indicando que los datos son inválidos y solicitando que intente nuevamente.
### Postcondiciones:
    El usuario ha creado un nuevo reporte de incidente urbano exitosamente y puede hacerle seguimiento a su estado.
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos del reporte durante el proceso de creación y almacenamiento.
- El sistema debe manejar adecuadamente los errores durante el proceso de creación del reporte y proporcionar mensajes claros al usuario.
- El sistema debe ser capaz de manejar la carga y almacenamiento de fotos de manera eficiente y confiable.
- El sistema debe permitir al usuario hacer seguimiento al estado de su reporte de manera clara y accesible.
- El sistema debe ser capaz de validar los datos ingresados por el usuario antes de crear el reporte.
- El sistema debe ser capaz de manejar múltiples reportes creados por diferentes usuarios sin comprometer el rendimiento.

## CU-05: Consultar reportes:
### Descripción:
    Permitir que un usuario visualice, filtre y explore reportes de incidentes en un listado detallado y sobre un mapa interactivo, con notificaciones de estado y una leyenda de colores e íconos para facilitar la interpretación.
### Actor:
    Ciudadano
### Precondiciones:
    El Ciudadano  debe haber iniciado sesión en la aplicación y tener acceso a internet.

### Flujo principal: 
1. El usuario se encuentra en la vista 02 Inicio.
2. El usuario puede ver un listado de reportes recientes, con información básica como título, tipo de problema, estado y fecha de creación.

### flujo alternativo:
#### Escenario 1: Sin reportes recientes
1. Si el usuario no ha creado ningún reporte recientemente, el backend devuelve un mensaje indicando que no hay reportes recientes disponibles.
2. El frontend muestra una lista vacía con un mensaje indicando que no hay reportes recientes disponibles y sugiere al usuario crear un nuevo reporte.
#### Escenario 2: Ver detalle del desde la lista de reporte Reciente 
1. El usuario hace click en un reporte del listado de reportes recientes.
2. El frontend redirige al usuario a la vista 05 Detalle.
3. El backend devuelve el detalle del reporte seleccionado.  
4. El frontend muestra el detalle del reporte, incluyendo su título, estado,fecha de actualización de estado ,las fotos adjuntas, descripción, tipo de problema,dirección, ubicación en un mapa y una lista con la cronología de cambios de estado del reporte donde apare el dia ,mes, hora. 
5. Si el reporte tiene el estado "Pendiente", el frontend adicionalmente muestra un mensaje indicando que el reporte está pendiente de revisión por parte de la oficina municipal.
6. Si el reporte tiene el estado "Revision", el  frontend adiconialmente muestra el nombre del técnico asignado al reporte. caso contrario muestra "Sin asignar tecnico".
7. Si el reporte tiene el estado "Finalizado", el frontend adicionalmente muestra el nombre del técnico asignado al reporte , comentario de resolución , las fotos de resolución.
8. Si el reporte tiene el estado "Rechazado", el frontend adicionalmente muestra el comentario de rechazo del operador.

#### Escenario 3: Ver detalle desde la vista de "Mis reportes"
1. El usuario hace click en el boton de "Mis reportes".
2. El frontend redirige al usuario a la vista 03 Mis reportes.
3. El backend devuelve un listado de los reportes creados por el usuario.
4. El frontend muestra el listado de los reportes creados por el usuario, con información básica como título, tipo de problema, estado y fecha de creación. Ademas filtros los reportes por estado [Todos, Pendiente, Revision, Finalizado, Rechazado] y un campo de búsqueda por titulo.
5. El usuario hace click en un reporte del listado de "Mis reportes".
6. El frontend redirige al usuario a la vista 05 Detalle.
7. El backend devuelve el detalle del reporte seleccionado.
#### Escenario 4: Ver detalle desde el mapa interactivo
1. El usuario hace click en el mapa interactivo.
2. El frontend redirige a la vista 06 Mapa
3. El backend devuelve un listado de reportes con su ubicación geográfica.
4. El frontend muestra los reportes en el mapa interactivo con íconos y colores que representan el tipo de problema y el estado del reporte. 
5. El usuario hace click en un reporte del mapa interactivo.
6. El frontend redirige al usuario a la vista 05 Detalle.

### Postcondiciones:
    El usuario ha visualizado el detalle de un reporte de incidente urbano exitosamente.
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos del reporte durante el proceso de visualización.
- El sistema debe manejar adecuadamente los errores durante el proceso de visualización del reporte y proporcionar mensajes claros al usuario.
- El sistema debe ser capaz de mostrar la información del reporte de manera clara y accesible para el usuario.
- El sistema debe ser capaz de manejar múltiples reportes visualizados por diferentes usuarios sin comprometer el rendimiento.
- El sistema debe ser capaz de mostrar la ubicación del reporte en un mapa interactivo de manera clara y precisa.

## CU-06: Validar reportes ciudadanos:
### Descripción:
    Permitir que un operador revise, apruebe o rechace los reportes recibidos, que notifique al ciudadano sobre la decisión tomada.
### Actor:
    Operador de Oficina Municipal.
### Precondiciones:
    El operador debe haber iniciado sesión en la aplicación y tener acceso a internet. El reporte debe haber sido creado por un ciudadano y estar en estado "Pendiente".
### Flujo principal:
1. El operador se encuentra en la vista 01 Cola de reportes.    
2. El operador puede ver un listado de reportes con información básica como título, tipo de problema, estado y fecha de actualización. También puede filtrar los reportes por estado [Todos, Pendiente, Revisión, Finalizado, Rechazado] y ver 3 contadores con el número de reportes en los estados Pendiente, Revisión y Finalizado.
3. El operador hace click en un reporte del listado de reportes pendientes. 
4. El frontend redirige al operador a la vista 02 Gestion.
5. El backend devuelve el detalle del reporte seleccionado. 
6. El frontend muestra el detalle del reporte, incluyendo su título, estado,fecha de actualización de estado ,las fotos adjuntas, descripción, tipo de problema,dirección, ubicación en un mapa.
7. El operador hace click en el botón "Aceptar Reporte" y Avisa que falta Asignar Técnico. 
8. El backend actualiza el estado del reporte a "Revisión", envía una notificación al ciudadano indicando que su reporte ha sido aceptado y está en revisión.

### Flujo alternativo:
#### Escenario 1: Sin reportes pendientes   
1. Si no hay reportes en estado "Pendiente", el backend devuelve un mensaje indicando que no hay reportes pendientes disponibles.
2. El frontend muestra una lista vacía con un mensaje indicando que no hay reportes pendientes disponibles y sugiere al operador esperar a que se creen nuevos reportes.
#### Escenario 2: Rechazar reporte
1. El operador hace click en el boton de "rechazar".
2. El frontend muestra un formulario para ingresar la razón del rechazo del reporte.
3. El operador ingresa la razón del rechazo y hace click en el botón "Confirmar rechazo".
2. El backend actualiza el comentario de resolución, el estado del reporte a "Rechazado" y envía una notificación al ciudadano indicando que su reporte ha sido rechazado.
3. El frontend muestra un mensaje de éxito indicando que el reporte ha sido rechazado correctamente y redirige al operador a la vista 01 Cola de reportes.
### Postcondiciones:
    El operador ha validado un reporte ciudadano exitosamente, notificado al ciudadano sobre la decisión tomada.
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos del reporte durante el proceso de validación.
- El sistema debe manejar adecuadamente los errores durante el proceso de validación del reporte y proporcionar mensajes claros al operador.
- El sistema debe ser capaz de actualizar el estado del reporte de manera eficiente y confiable.

## CU-07: Asignar técnicos a reportes en revisión:
### Descripción:
    Permitir que un operador asigne un técnico de campo a un reporte que ya fue aceptado y se encuentra en estado "Revisión", sin cambiar el estado del reporte, y que notifique al ciudadano que su reporte ha sido asignado a un técnico.
### Actor:
    Operador de Oficina Municipal.
### Precondiciones:
    El operador debe haber iniciado sesión en la aplicación y tener acceso a internet. El reporte debe haber sido creado por un ciudadano y estar en estado "Revisión".
### Flujo principal:
1. El operador se encuentra en la vista 01 Cola de reportes.    
2. El operador puede ver un listado de reportes filtrable por estado [Pendiente, Revisión, Finalizado, Rechazado] con información básica como título, tipo de problema, estado y fecha de actualización.
3. El operador hace click en un reporte del listado de reportes en revisión. 
4. Si el reporte seleccionado tiene el estado "Revisión" y no tiene un técnico asignado, el frontend muestra adicionalmente "Sin tecnico asignado" debajo del estado del reporte. Caso contrario, si el reporte tiene un técnico asignado, el frontend muestra el nombre del técnico asignado debajo del estado del reporte.
5. El frontend redirige al operador a la vista 02 Gestion.
6. El backend devuelve el detalle del reporte seleccionado. 
7. El frontend muestra el detalle del reporte, incluyendo su título, estado,fecha de actualización de estado ,las fotos adjuntas, descripción, tipo de problema,dirección, ubicación en un mapa.
8. El operador hace click en el botón "Asignar Técnico".
9. El backend no cambia el estado , asigna un técnico y envía una notificación al ciudadano indicando que su reporte ha sido asignado a un técnico.

### Flujo alternativo:
#### Escenario 1: Sin técnicos disponibles   
1. Si no hay técnicos disponibles, el backend devuelve un mensaje indicando que no hay técnicos disponibles.
2. El frontend muestra una lista vacía con un mensaje indicando que no hay técnicos disponibles y sugiere al operador esperar a que se registren nuevos técnicos.

### Postcondiciones:
    El operador ha asignado un técnico a un reporte exitosamente, notificado al ciudadano sobre la decisión tomada.
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos del reporte durante el proceso de asignación.
- El sistema debe manejar adecuadamente los errores durante el proceso de asignación del reporte y proporcionar mensajes claros al operador.
- El sistema debe ser capaz de actualizar el estado del reporte de manera eficiente y confiable.

## CU-08: Atender reportes asignados:
### Descripción:
   Permitir que un técnico revise las tareas asignadas, actualice el estado del reporte, aporte evidencia fotográfica y comentarios de la solución, y confirme la finalización del trabajo en campo.
### Actor:
    Técnico de Campo Municipal.
### Precondiciones:
    El técnico debe haber iniciado sesión en la aplicación y tener acceso a internet. El reporte debe haber sido asignado al técnico por un operador y estar en estado "Revisión".
### Flujo principal:
1. El técnico se encuentra en la vista 01 Mis asignaciones.
2. El técnico puede ver un listado de reportes asignados con información básica como título, tipo de problema, estado , fecha de actualización y tambien ve 2 contadores con el numero de reportes en cada estado [Revisión, Finalizado] por parte del técnico.
3. El técnico hace click en un reporte del listado de reportes asignados.
4. El frontend redirige al técnico a la vista 02 informacion.
5. El backend devuelve el detalle del reporte seleccionado. 
6. El frontend muestra el detalle del reporte, incluyendo su título, estado,fecha de actualización de estado ,las fotos adjuntas, descripción, tipo de problema,dirección, ubicación en un mapa y una lista con la cronología de cambios de estado del reporte donde apare el dia ,mes, hora.
7. El técnico hace click en el boton "Iniciar trabajo de campo".
8. El frontend redirige al técnico a la vista 03 Evidencia donde puede tomar fotos y escribir comentarios de la solución.
9. El técnico ingresa los comentarios de la solución y adjunta fotos de la solución (max 5 fotos).
10. El técnico hace click en el botón "Finalizar reporte".
11. El backend actualiza el estado del reporte a "Finalizado", guarda el comentario de resolución, las fotos de la solución y envía una notificación al ciudadano indicando que su reporte ha sido finalizado.
### Flujo alternativo:
#### Escenario 1: Sin reportes asignados    
1. Si no hay reportes asignados al técnico, el backend devuelve un mensaje indicando que no hay reportes asignados disponibles.
2. El frontend muestra una lista vacía con un mensaje indicando que no hay reportes asignados disponibles y sugiere al técnico esperar a que se asignen nuevos reportes.
### Postcondiciones:
    El técnico ha atendido un reporte asignado exitosamente, actualizado el estado del reporte a "Finalizado" y notificado al ciudadano sobre la finalización del trabajo.  
### Requisitos no funcionales:
- El sistema debe garantizar la privacidad y seguridad de los datos del reporte durante el proceso de atención.
- El sistema debe manejar adecuadamente los errores durante el proceso de atención del reporte y proporcionar mensajes claros al técnico.
- El sistema debe ser capaz de actualizar el estado del reporte de manera eficiente y confiable.    
- El sistema debe ser capaz de manejar la carga y almacenamiento de fotos de manera eficiente y confiable durante el proceso de atención del reporte.

Condiciones generales adicionales a todos los CU:
- Existen 3 roles de usuario: Ciudadano, Operador de Oficina Municipal y Técnico de Campo Municipal. Cada rol tiene permisos y vistas específicas dentro de la aplicación.
- Existen solamente 4 estados para los reportes: Pendiente, Revisión, Finalizado, Rechazado. El flujo de estados es: un reporte nace en "Pendiente"; el operador lo acepta pasándolo a "Revisión" o lo rechaza pasándolo a "Rechazado"; estando en "Revisión" el operador le asigna un técnico (el estado se mantiene en "Revisión"); cuando el técnico concluye el trabajo de campo el reporte pasa a "Finalizado". No existe paso de auditoría.
- Las vistas para el Ciudadano son: 02 Inicio, 03 Mis reportes, 04 Reportar, 05 Detalle, 06 Mapa.  
- Las vistas para el Operador de Oficina Municipal son: 01 Cola de reportes, 02 Gestion.
- Las vistas para el Técnico de Campo Municipal son: 01 Mis asignaciones, 02 Informacion, 03 Evidencia. 
- Las vistas 01 Login, 08 Recuperar contraseña y 09 Restablecer contraseña son vistas comunes para los 3 roles de usuario.
- La vista 07 Registro es exclusiva para el rol de Ciudadano debido que no cualquiera puede registrarse como Operador o técnico eso se implementara en el futuro.
