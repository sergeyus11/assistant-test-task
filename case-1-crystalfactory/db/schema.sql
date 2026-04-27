-- CrystalFactory test task — схема SQLite базы
--
-- Простая модель: номенклатура (один справочник) + BOM (спецификация)
-- BOM хранится в виде дерева: каждая строка ссылается на родителя через parent_id

CREATE TABLE nomenclature (
    id INTEGER PRIMARY KEY,
    code TEXT UNIQUE,                  -- код из 1С (УТ000000077 и т.п.)
    name TEXT NOT NULL,                -- очищенное название
    name_raw TEXT,                     -- оригинал из CSV (для traceability)
    type TEXT NOT NULL CHECK(type IN ('ingredient', 'semi_finished', 'finished', 'packaging')),
    unit TEXT NOT NULL,                -- кг, г, шт, м, л
    category TEXT,                     -- мука, сыр, упаковка...
    notes TEXT
);

CREATE TABLE bom (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,       -- ссылка на номенклатуру (готовое изделие)
    name TEXT NOT NULL,                -- дублируем имя для удобства запросов
    pieces_per_box INTEGER,
    notes TEXT,
    FOREIGN KEY (product_id) REFERENCES nomenclature(id)
);

CREATE TABLE bom_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bom_id INTEGER NOT NULL,
    parent_item_id INTEGER,            -- NULL = прямой компонент изделия, иначе — компонент полуфабриката
    nomenclature_id INTEGER NOT NULL,  -- ссылка на компонент в справочнике
    quantity REAL NOT NULL,
    unit TEXT NOT NULL,
    level INTEGER NOT NULL,            -- 1, 2, 3, 4 — уровень вложенности
    notes TEXT,
    FOREIGN KEY (bom_id) REFERENCES bom(id),
    FOREIGN KEY (parent_item_id) REFERENCES bom_items(id),
    FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id)
);

CREATE INDEX idx_bom_items_bom ON bom_items(bom_id);
CREATE INDEX idx_bom_items_parent ON bom_items(parent_item_id);
CREATE INDEX idx_nomenclature_type ON nomenclature(type);
