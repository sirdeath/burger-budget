#!/usr/bin/env python3
"""
Burger Budget - Seed DB Generator

5개 프랜차이즈(맥도날드, 버거킹, KFC, 맘스터치, 롯데리아)의
대략적 실제 메뉴 데이터를 SQLite DB로 생성합니다.

Usage:
    python3 scripts/generate_seed_db.py
"""

import os
import sqlite3

# Output path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
DB_PATH = os.path.join(PROJECT_DIR, 'assets', 'menu_seed.db')

# ── Menu Data ────────────────────────────────────────────────
# (id, franchise, name, type, price, calories, imageUrl, tags)

MENUS = [
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # McDonald's (mcd) — 2025-2026 가격 기준
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mcd_burger_01', 'mcd', '빅맥', 'burger', 5800, 563, None, '인기,시그니처'),
    ('mcd_burger_02', 'mcd', '맥스파이시 상하이 버거', 'burger', 5800, 520, None, '매운,인기'),
    ('mcd_burger_03', 'mcd', '1955 버거', 'burger', 6700, 618, None, '프리미엄'),
    ('mcd_burger_04', 'mcd', '쿼터파운더 치즈', 'burger', 5800, 524, None, '시그니처'),
    ('mcd_burger_05', 'mcd', '맥치킨', 'burger', 3700, 400, None, '가성비'),
    ('mcd_burger_06', 'mcd', '더블 쿼터파운더 치즈', 'burger', 7700, 749, None, '프리미엄'),
    ('mcd_burger_07', 'mcd', '치즈버거', 'burger', 3000, 302, None, '가성비'),
    ('mcd_burger_08', 'mcd', '에그 불고기 버거', 'burger', 4200, 430, None, ''),
    ('mcd_burger_09', 'mcd', '베이컨 토마토 디럭스', 'burger', 7200, 580, None, '프리미엄'),
    # Sides
    ('mcd_side_01', 'mcd', '프렌치 프라이 (M)', 'side', 2700, 332, None, '인기'),
    ('mcd_side_02', 'mcd', '맥너겟 6조각', 'side', 4100, 270, None, '인기'),
    ('mcd_side_03', 'mcd', '치즈스틱 3조각', 'side', 3000, 280, None, ''),
    ('mcd_side_04', 'mcd', '프렌치 프라이 (L)', 'side', 3400, 490, None, ''),
    ('mcd_side_05', 'mcd', '맥너겟 10조각', 'side', 5900, 450, None, ''),
    ('mcd_side_06', 'mcd', '맥윙 2조각', 'side', 3200, 240, None, ''),
    # Drinks
    ('mcd_drink_01', 'mcd', '코카콜라 (M)', 'drink', 2100, 150, None, ''),
    ('mcd_drink_02', 'mcd', '아메리카노', 'drink', 2500, 10, None, ''),
    ('mcd_drink_03', 'mcd', '바닐라 쉐이크 (M)', 'drink', 3000, 530, None, ''),
    ('mcd_drink_04', 'mcd', '스프라이트 (M)', 'drink', 2100, 140, None, ''),
    ('mcd_drink_05', 'mcd', '딸기 쉐이크 (M)', 'drink', 3000, 510, None, ''),
    # Desserts
    ('mcd_dessert_01', 'mcd', '맥플러리 오레오', 'dessert', 3500, 340, None, '인기'),
    ('mcd_dessert_02', 'mcd', '애플파이', 'dessert', 2000, 240, None, '가성비'),
    ('mcd_dessert_03', 'mcd', '선데이 아이스크림', 'dessert', 2000, 200, None, '가성비'),
    ('mcd_dessert_04', 'mcd', '콘 아이스크림', 'dessert', 1000, 120, None, '가성비'),
    # Sets
    ('mcd_set_01', 'mcd', '빅맥 세트', 'set', 8800, 1045, None, '인기,시그니처'),
    ('mcd_set_02', 'mcd', '맥스파이시 상하이 세트', 'set', 8800, 1002, None, '매운,인기'),
    ('mcd_set_03', 'mcd', '1955 버거 세트', 'set', 9700, 1100, None, '프리미엄'),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burger King (bk) — 2026.02 인상 반영
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('bk_burger_01', 'bk', '와퍼', 'burger', 7400, 660, None, '시그니처,인기'),
    ('bk_burger_02', 'bk', '와퍼 주니어', 'burger', 5000, 370, None, '가성비'),
    ('bk_burger_03', 'bk', '콰트로 치즈 와퍼', 'burger', 8200, 730, None, '프리미엄'),
    ('bk_burger_04', 'bk', '통새우 와퍼', 'burger', 8200, 580, None, '인기'),
    ('bk_burger_05', 'bk', '치킨버거', 'burger', 3900, 420, None, '가성비'),
    ('bk_burger_06', 'bk', '불고기 와퍼', 'burger', 7400, 580, None, ''),
    ('bk_burger_07', 'bk', '몬스터 와퍼', 'burger', 9600, 870, None, '프리미엄'),
    ('bk_burger_08', 'bk', '비프 불고기 버거', 'burger', 5200, 450, None, ''),
    ('bk_burger_09', 'bk', '더블 와퍼', 'burger', 9800, 900, None, '프리미엄'),
    # Sides
    ('bk_side_01', 'bk', '어니언링', 'side', 2800, 320, None, '인기'),
    ('bk_side_02', 'bk', '프렌치프라이 (M)', 'side', 2300, 340, None, ''),
    ('bk_side_03', 'bk', '너겟킹 5조각', 'side', 2300, 260, None, ''),
    ('bk_side_04', 'bk', '치즈프라이', 'side', 3200, 410, None, ''),
    ('bk_side_05', 'bk', '프렌치프라이 (L)', 'side', 2800, 490, None, ''),
    ('bk_side_06', 'bk', '치킨프라이 4조각', 'side', 3000, 300, None, ''),
    # Drinks
    ('bk_drink_01', 'bk', '코카콜라 (M)', 'drink', 2100, 150, None, ''),
    ('bk_drink_02', 'bk', '아메리카노', 'drink', 1600, 10, None, ''),
    ('bk_drink_03', 'bk', '쉐이크 (M)', 'drink', 3500, 540, None, ''),
    ('bk_drink_04', 'bk', '스프라이트 (M)', 'drink', 2100, 140, None, ''),
    ('bk_drink_05', 'bk', '아이스티 (M)', 'drink', 2300, 80, None, ''),
    # Desserts
    ('bk_dessert_01', 'bk', '킹 선데이 초코', 'dessert', 2500, 280, None, '인기'),
    ('bk_dessert_02', 'bk', '킹 선데이 딸기', 'dessert', 2500, 260, None, ''),
    ('bk_dessert_03', 'bk', '킹콘', 'dessert', 1500, 180, None, '가성비'),
    # Sets
    ('bk_set_01', 'bk', '와퍼 세트', 'set', 10200, 1150, None, '시그니처,인기'),
    ('bk_set_02', 'bk', '콰트로 치즈 와퍼 세트', 'set', 11000, 1220, None, '프리미엄'),
    ('bk_set_03', 'bk', '치킨버거 세트', 'set', 6700, 910, None, '가성비'),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # KFC (kfc) — 2025-2026 가격 기준
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('kfc_burger_01', 'kfc', '징거버거', 'burger', 6200, 480, None, '시그니처,인기'),
    ('kfc_burger_02', 'kfc', '타워버거', 'burger', 7100, 560, None, '인기'),
    ('kfc_burger_03', 'kfc', '치킨필렛버거', 'burger', 5200, 420, None, '가성비'),
    ('kfc_burger_04', 'kfc', '불고기버거', 'burger', 4600, 390, None, '가성비'),
    ('kfc_burger_05', 'kfc', '더블다운맥스', 'burger', 8500, 650, None, '프리미엄'),
    ('kfc_burger_06', 'kfc', '징거더블다운', 'burger', 7800, 620, None, '인기'),
    ('kfc_burger_07', 'kfc', '칠리 징거버거', 'burger', 7000, 510, None, '매운'),
    # Sides
    ('kfc_side_01', 'kfc', '핫크리스피치킨 1조각', 'side', 3200, 290, None, '시그니처,인기'),
    ('kfc_side_02', 'kfc', '핫크리스피치킨 2조각', 'side', 5800, 580, None, '시그니처'),
    ('kfc_side_03', 'kfc', '코울슬로', 'side', 2100, 180, None, ''),
    ('kfc_side_04', 'kfc', '비스켓', 'side', 1800, 240, None, ''),
    ('kfc_side_05', 'kfc', '프렌치프라이 (M)', 'side', 2400, 340, None, ''),
    ('kfc_side_06', 'kfc', '핫크리스피치킨 3조각', 'side', 8400, 870, None, ''),
    ('kfc_side_07', 'kfc', '커널콘샐러드', 'side', 2100, 120, None, ''),
    # Drinks
    ('kfc_drink_01', 'kfc', '코카콜라 (M)', 'drink', 2100, 150, None, ''),
    ('kfc_drink_02', 'kfc', '아메리카노', 'drink', 1800, 10, None, ''),
    ('kfc_drink_03', 'kfc', '커널스위트콘샐러드', 'drink', 2300, 100, None, ''),
    ('kfc_drink_04', 'kfc', '스프라이트 (M)', 'drink', 2100, 140, None, ''),
    ('kfc_drink_05', 'kfc', '제로콜라 (M)', 'drink', 2100, 0, None, ''),
    # Desserts
    ('kfc_dessert_01', 'kfc', '에그타르트', 'dessert', 2200, 210, None, '인기'),
    ('kfc_dessert_02', 'kfc', '트위스터 아이스크림', 'dessert', 1800, 200, None, '가성비'),
    ('kfc_dessert_03', 'kfc', '초코 파이', 'dessert', 2500, 280, None, ''),
    # Sets
    ('kfc_set_01', 'kfc', '징거버거 세트', 'set', 8400, 970, None, '시그니처,인기'),
    ('kfc_set_02', 'kfc', '타워버거 세트', 'set', 9300, 1050, None, '인기'),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Mom's Touch (mom) — 2025-2026 가격 기준
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mom_burger_01', 'mom', '싸이버거', 'burger', 4900, 480, None, '시그니처,인기,가성비'),
    ('mom_burger_02', 'mom', '불싸이버거', 'burger', 5100, 520, None, '매운,인기'),
    ('mom_burger_03', 'mom', '인크레더블버거', 'burger', 6000, 590, None, '프리미엄'),
    ('mom_burger_04', 'mom', '치즈불싸이버거', 'burger', 5600, 560, None, '매운'),
    ('mom_burger_05', 'mom', '흑미새우버거', 'burger', 5200, 420, None, ''),
    ('mom_burger_06', 'mom', '딥치즈버거', 'burger', 5400, 510, None, ''),
    ('mom_burger_07', 'mom', '화이트갈릭싸이버거', 'burger', 5500, 500, None, '인기'),
    ('mom_burger_08', 'mom', '언빌리버블버거', 'burger', 6500, 610, None, '프리미엄'),
    # Sides
    ('mom_side_01', 'mom', '후라이드치킨 1조각', 'side', 2000, 280, None, '가성비'),
    ('mom_side_02', 'mom', '양념치킨 1조각', 'side', 2300, 300, None, ''),
    ('mom_side_03', 'mom', '감자튀김 (M)', 'side', 2500, 340, None, ''),
    ('mom_side_04', 'mom', '치즈스틱 3조각', 'side', 2800, 260, None, ''),
    ('mom_side_05', 'mom', '케이준감자 (M)', 'side', 3500, 380, None, '인기'),
    ('mom_side_06', 'mom', '후라이드치킨 2조각', 'side', 3800, 560, None, ''),
    # Drinks
    ('mom_drink_01', 'mom', '코카콜라 (M)', 'drink', 1800, 150, None, ''),
    ('mom_drink_02', 'mom', '아메리카노', 'drink', 2000, 10, None, ''),
    ('mom_drink_03', 'mom', '레모네이드', 'drink', 2500, 120, None, ''),
    ('mom_drink_04', 'mom', '제로콜라 (M)', 'drink', 1800, 0, None, ''),
    ('mom_drink_05', 'mom', '아이스티', 'drink', 2000, 80, None, ''),
    # Desserts
    ('mom_dessert_01', 'mom', '허니버터감자 (M)', 'dessert', 3800, 420, None, '인기'),
    ('mom_dessert_02', 'mom', '아이스크림 콘', 'dessert', 1200, 130, None, '가성비'),
    ('mom_dessert_03', 'mom', '치즈볼 5개', 'dessert', 3000, 320, None, ''),
    # Sets
    ('mom_set_01', 'mom', '싸이버거 세트', 'set', 7300, 970, None, '시그니처,인기,가성비'),
    ('mom_set_02', 'mom', '불싸이버거 세트', 'set', 7500, 1010, None, '매운,인기'),
    ('mom_set_03', 'mom', '인크레더블버거 세트', 'set', 8400, 1080, None, '프리미엄'),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Lotteria (lot) — 2025-2026 가격 기준
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('lot_burger_01', 'lot', '불고기버거', 'burger', 5000, 400, None, '시그니처,인기,가성비'),
    ('lot_burger_02', 'lot', 'AZ버거', 'burger', 6500, 520, None, '인기'),
    ('lot_burger_03', 'lot', '한우불고기버거', 'burger', 9000, 530, None, '프리미엄'),
    ('lot_burger_04', 'lot', '새우버거', 'burger', 5000, 410, None, ''),
    ('lot_burger_05', 'lot', '모짜렐라인더버거', 'burger', 5700, 580, None, '프리미엄'),
    ('lot_burger_06', 'lot', '리아 불고기', 'burger', 5000, 420, None, '가성비'),
    ('lot_burger_07', 'lot', '데리버거', 'burger', 3700, 380, None, '가성비'),
    ('lot_burger_08', 'lot', '클래식 치즈버거', 'burger', 5500, 460, None, ''),
    ('lot_burger_09', 'lot', '리아 새우', 'burger', 5000, 400, None, ''),
    # Sides
    ('lot_side_01', 'lot', '양념감자', 'side', 2600, 300, None, '인기'),
    ('lot_side_02', 'lot', '어니언링', 'side', 2800, 310, None, ''),
    ('lot_side_03', 'lot', '치즈스틱', 'side', 2800, 270, None, ''),
    ('lot_side_04', 'lot', '프렌치프라이 (M)', 'side', 2500, 330, None, ''),
    ('lot_side_05', 'lot', '치킨너겟 5조각', 'side', 3100, 280, None, ''),
    # Drinks
    ('lot_drink_01', 'lot', '코카콜라 (M)', 'drink', 2100, 150, None, ''),
    ('lot_drink_02', 'lot', '아메리카노', 'drink', 2500, 10, None, ''),
    ('lot_drink_03', 'lot', '밀크쉐이크', 'drink', 3300, 480, None, ''),
    ('lot_drink_04', 'lot', '아이스티', 'drink', 2300, 80, None, ''),
    ('lot_drink_05', 'lot', '제로콜라 (M)', 'drink', 2100, 0, None, ''),
    # Desserts
    ('lot_dessert_01', 'lot', '소프트콘', 'dessert', 1200, 150, None, '가성비'),
    ('lot_dessert_02', 'lot', '선데이 초코', 'dessert', 2500, 260, None, '인기'),
    ('lot_dessert_03', 'lot', '롯데리아 호떡', 'dessert', 1800, 230, None, ''),
    # Sets
    ('lot_set_01', 'lot', '불고기버거 세트', 'set', 7300, 880, None, '시그니처,인기,가성비'),
    ('lot_set_02', 'lot', 'AZ버거 세트', 'set', 8800, 1000, None, '인기'),
    ('lot_set_03', 'lot', '한우불고기버거 세트', 'set', 11500, 1010, None, '프리미엄'),
]


def generate_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE menus (
            id        TEXT PRIMARY KEY,
            franchise TEXT NOT NULL,
            name      TEXT NOT NULL,
            type      TEXT NOT NULL CHECK(type IN ('burger','side','drink','set','dessert')),
            price     INTEGER NOT NULL,
            calories  INTEGER,
            imageUrl  TEXT,
            tags      TEXT DEFAULT ''
        )
    ''')

    cursor.execute('''
        CREATE INDEX idx_menus_franchise ON menus(franchise)
    ''')

    cursor.execute('''
        CREATE INDEX idx_menus_price ON menus(price)
    ''')

    cursor.execute('''
        CREATE INDEX idx_menus_name ON menus(name)
    ''')

    cursor.executemany(
        'INSERT INTO menus (id, franchise, name, type, price, calories, imageUrl, tags) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        MENUS,
    )

    conn.commit()

    # ── Summary ──
    cursor.execute('SELECT COUNT(*) FROM menus')
    total = cursor.fetchone()[0]

    cursor.execute(
        'SELECT franchise, COUNT(*) FROM menus GROUP BY franchise ORDER BY franchise'
    )
    by_franchise = cursor.fetchall()

    cursor.execute(
        'SELECT type, COUNT(*) FROM menus GROUP BY type ORDER BY type'
    )
    by_type = cursor.fetchall()

    conn.close()

    print(f'Seed DB generated: {DB_PATH}')
    print(f'Total items: {total}')
    print()
    print('By franchise:')
    for franchise, count in by_franchise:
        print(f'  {franchise}: {count}')
    print()
    print('By type:')
    for menu_type, count in by_type:
        print(f'  {menu_type}: {count}')


if __name__ == '__main__':
    generate_db()
