delete from public.menu_items;

insert into public.menu_items (
  id,
  name,
  description,
  price,
  category,
  available,
  recommended,
  tags,
  image_url
) values
-- Res: tipos de corte
(
  'res-ribeye',
  'Ribeye Angus a la parrilla',
  'Corte jugoso de ribeye Angus con mantequilla de hierbas, papas rusticas y vegetales asados.',
  78000,
  'Res',
  true,
  true,
  '["res", "ribeye", "angus", "parrilla", "premium", "carne"]'::jsonb,
  ''
),
(
  'res-punta-anca',
  'Punta de anca ahumada',
  'Punta de anca sellada al carbon con chimichurri, yuca crocante y ensalada fresca.',
  62000,
  'Res',
  true,
  false,
  '["res", "punta de anca", "carbon", "ahumado", "carne"]'::jsonb,
  ''
),
(
  'res-lomo-medallones',
  'Medallones de lomo en salsa de vino',
  'Medallones de lomo fino con reduccion de vino tinto, pure cremoso y champinones.',
  69000,
  'Res',
  true,
  true,
  '["res", "lomo", "vino", "champinones", "elegante", "carne"]'::jsonb,
  ''
),

-- Pollo: diferentes presentaciones
(
  'pollo-parrilla',
  'Pollo a la parrilla con hierbas',
  'Pechuga de pollo marinada con limon y hierbas, acompanada de arroz aromatico y ensalada.',
  38000,
  'Pollo',
  true,
  true,
  '["pollo", "parrilla", "saludable", "proteina", "hierbas"]'::jsonb,
  ''
),
(
  'pollo-crispy',
  'Pollo crispy artesanal',
  'Filetes de pollo crocante con salsa miel mostaza, papas casco y slaw de la casa.',
  42000,
  'Pollo',
  true,
  false,
  '["pollo", "crispy", "crocante", "papas", "miel mostaza"]'::jsonb,
  ''
),
(
  'pollo-curry',
  'Pollo al curry tropical',
  'Trozos de pollo en curry suave con leche de coco, mango, arroz jazmin y cilantro.',
  45000,
  'Pollo',
  true,
  true,
  '["pollo", "curry", "coco", "mango", "arroz", "tropical"]'::jsonb,
  ''
),

-- Pastas: diferentes tipos
(
  'pasta-carbonara',
  'Spaghetti carbonara cremosa',
  'Spaghetti al dente con salsa cremosa, panceta dorada, queso parmesano y pimienta negra.',
  41000,
  'Pastas',
  true,
  true,
  '["pasta", "spaghetti", "carbonara", "cremosa", "queso"]'::jsonb,
  ''
),
(
  'pasta-pesto',
  'Fettuccine al pesto',
  'Fettuccine con pesto de albahaca, nueces, parmesano y tomates cherry confitados.',
  39000,
  'Pastas',
  true,
  false,
  '["pasta", "fettuccine", "pesto", "albahaca", "vegetariano"]'::jsonb,
  ''
),
(
  'pasta-bolognesa',
  'Rigatoni bolognesa lenta',
  'Rigatoni con ragú de res cocido lentamente, tomate San Marzano y queso madurado.',
  44000,
  'Pastas',
  true,
  true,
  '["pasta", "rigatoni", "bolognesa", "res", "tomate"]'::jsonb,
  ''
),

-- Hamburguesas
(
  'burger-clasica',
  'Hamburguesa clasica OrdeNow',
  'Carne de res artesanal, queso cheddar, lechuga, tomate, cebolla caramelizada y salsa de la casa.',
  36000,
  'Hamburguesas',
  true,
  true,
  '["hamburguesa", "res", "cheddar", "clasica", "papas"]'::jsonb,
  ''
),
(
  'burger-bbq',
  'Hamburguesa BBQ bacon',
  'Carne de res, tocineta crocante, queso americano, aros de cebolla y salsa BBQ ahumada.',
  42000,
  'Hamburguesas',
  true,
  false,
  '["hamburguesa", "bbq", "bacon", "tocineta", "ahumada"]'::jsonb,
  ''
),
(
  'burger-pollo',
  'Hamburguesa crispy chicken',
  'Pollo crocante, queso mozzarella, pepinillos, lechuga fresca y salsa ranch.',
  38000,
  'Hamburguesas',
  true,
  true,
  '["hamburguesa", "pollo", "crispy", "ranch", "crocante"]'::jsonb,
  ''
),

-- Vegano
(
  'vegano-bowl',
  'Bowl vegano mediterraneo',
  'Quinoa, hummus, garbanzos especiados, pepino, tomate, aceitunas y vinagreta de limon.',
  34000,
  'Vegano',
  true,
  true,
  '["vegano", "quinoa", "hummus", "garbanzos", "saludable"]'::jsonb,
  ''
),
(
  'vegano-tacos',
  'Tacos veganos de hongos',
  'Tortillas suaves con hongos salteados, guacamole, pico de gallo y crema vegetal.',
  32000,
  'Vegano',
  true,
  false,
  '["vegano", "tacos", "hongos", "guacamole", "mexicano"]'::jsonb,
  ''
),
(
  'vegano-burger',
  'Burger vegana de lentejas',
  'Medallon de lentejas y vegetales, pan artesanal, aguacate, tomate y mayonesa vegana.',
  35000,
  'Vegano',
  true,
  true,
  '["vegano", "hamburguesa", "lentejas", "aguacate", "vegetal"]'::jsonb,
  ''
),

-- Bebidas
(
  'bebida-limonada-coco',
  'Limonada de coco',
  'Bebida fria de limon y coco, cremosa, refrescante y ligeramente dulce.',
  16000,
  'Bebidas',
  true,
  true,
  '["bebida", "limonada", "coco", "fria", "refrescante"]'::jsonb,
  ''
),
(
  'bebida-frutos-rojos',
  'Soda de frutos rojos',
  'Soda artesanal con frutos rojos, hierbabuena y burbujas suaves.',
  15000,
  'Bebidas',
  true,
  false,
  '["bebida", "soda", "frutos rojos", "refrescante"]'::jsonb,
  ''
),
(
  'bebida-cafe-frio',
  'Cafe frio de vainilla',
  'Cafe frio con vainilla, leche cremosa y hielo, ideal para cerrar la comida.',
  14000,
  'Bebidas',
  true,
  false,
  '["bebida", "cafe", "vainilla", "frio", "postre"]'::jsonb,
  ''
);
