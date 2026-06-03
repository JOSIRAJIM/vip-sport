# Sport Store POS

Aplicacion web para una tienda de ropa deportiva con inventario, POS, turnos, cierre de caja, reportes diarios, usuarios por rol, tirilla imprimible y base de datos MariaDB.

## Stack

- Node.js + Express para API.
- Vue 3 + Vite para frontend.
- MariaDB para persistencia.
- Docker Compose para levantar app y base de datos.

## Ejecutar

1. Copia variables de entorno:

```bash
cp .env.example .env
```

2. Ajusta `JWT_SECRET` y las claves de base de datos en `.env`.

3. Levanta los contenedores:

```bash
docker compose up --build
```

4. Abre:

```text
http://localhost:3000
```

## Usuarios demo

| Usuario | Contrasena | Rol |
| --- | --- | --- |
| admin | Admin123! | admin |
| supervisor | Supervisor123! | supervisor |
| cajero | Cajero123! | cajero |
| inventario | Inventario123! | inventario |

## Funciones incluidas

- Frontend Vue con POS, busqueda de productos, carrito, multiples formas de pago y tirilla imprimible.
- Descuento automatico de inventario al registrar una venta.
- Turnos por usuario con apertura, cierre y diferencia de caja.
- Reporte diario de ventas, formas de pago y productos mas vendidos.
- Inventario con alta/edicion de productos y movimientos de entrada, salida o conteo.
- Usuarios con roles `admin`, `supervisor`, `cajero` e `inventario`.

## Endpoints principales

- `POST /api/auth/login`
- `GET /api/products`
- `POST /api/products`
- `POST /api/products/:id/stock`
- `POST /api/shifts/open`
- `POST /api/shifts/:id/close`
- `POST /api/sales`
- `GET /api/reports/daily?date=YYYY-MM-DD`
- `GET /api/users`

## Notas operativas

- La tirilla se imprime desde el navegador usando la vista de impresion.
- Cada venta se guarda en una transaccion: valida turno abierto, valida stock, inserta venta/pagos/items, registra movimientos y actualiza stock.
- Para produccion cambia `JWT_SECRET`, contrasenas y configura respaldos del volumen `mariadb_data`.

## Estructura

- `frontend/`: aplicacion Vue 3.
- `backend/src/`: API Express.
- `db/init/`: esquema y datos iniciales MariaDB.
- `backend/Dockerfile`: compila Vue y arma la imagen final de la app.
