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
    # McDonald's (mcd)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mcd_burger_01', 'mcd', '빅맥', 'burger', 6500, 550, None, '인기,시그니처'),
    ('mcd_burger_02', 'mcd', '맥스파이시 상하이 버거', 'burger', 7300, 530, None, '매운,인기'),
    ('mcd_burger_03', 'mcd', '1955 버거', 'burger', 7500, 620, None, '프리미엄'),
    ('mcd_burger_04', 'mcd', '쿼터파운더 치즈', 'burger', 7000, 520, None, '시그니처'),
    ('mcd_burger_05', 'mcd', '맥치킨', 'burger', 3500, 400, None, '가성비'),
    ('mcd_burger_06', 'mcd', '더블 쿼터파운더 치즈', 'burger', 8500, 740, None, '프리미엄'),
    ('mcd_burger_07', 'mcd', '치즈버거', 'burger', 3000, 300, None, '가성비'),
    # Sides
    ('mcd_side_01', 'mcd', '프렌치 프라이 (M)', 'side', 2800, 340, None, '인기'),
    ('mcd_side_02', 'mcd', '맥너겟 6조각', 'side', 3500, 270, None, '인기'),
    ('mcd_side_03', 'mcd', '치즈스틱 3조각', 'side', 3000, 280, None, ''),
    ('mcd_side_04', 'mcd', '프렌치 프라이 (L)', 'side', 3300, 490, None, ''),
    # Drinks
    ('mcd_drink_01', 'mcd', '코카콜라 (M)', 'drink', 2200, 150, None, ''),
    ('mcd_drink_02', 'mcd', '아메리카노', 'drink', 2500, 10, None, ''),
    ('mcd_drink_03', 'mcd', '바닐라 쉐이크 (M)', 'drink', 3300, 530, None, ''),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burger King (bk)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('bk_burger_01', 'bk', '와퍼', 'burger', 8200, 660, None, '시그니처,인기'),
    ('bk_burger_02', 'bk', '와퍼 주니어', 'burger', 5200, 370, None, '가성비'),
    ('bk_burger_03', 'bk', '콰트로 치즈 와퍼', 'burger', 9500, 730, None, '프리미엄'),
    ('bk_burger_04', 'bk', '통새우 와퍼', 'burger', 8800, 580, None, '인기'),
    ('bk_burger_05', 'bk', '치킨버거', 'burger', 5000, 420, None, '가성비'),
    ('bk_burger_06', 'bk', '불고기 와퍼', 'burger', 7500, 580, None, ''),
    ('bk_burger_07', 'bk', '몬스터 와퍼', 'burger', 10900, 870, None, '프리미엄'),
    # Sides
    ('bk_side_01', 'bk', '어니언링', 'side', 2800, 320, None, '인기'),
    ('bk_side_02', 'bk', '프렌치프라이 (M)', 'side', 2800, 340, None, ''),
    ('bk_side_03', 'bk', '너겟킹 5조각', 'side', 3200, 260, None, ''),
    ('bk_side_04', 'bk', '치즈프라이', 'side', 3500, 410, None, ''),
    # Drinks
    ('bk_drink_01', 'bk', '코카콜라 (M)', 'drink', 2200, 150, None, ''),
    ('bk_drink_02', 'bk', '아메리카노', 'drink', 2500, 10, None, ''),
    ('bk_drink_03', 'bk', '쉐이크 (M)', 'drink', 3500, 540, None, ''),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # KFC (kfc)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('kfc_burger_01', 'kfc', '징거버거', 'burger', 6900, 480, None, '시그니처,인기'),
    ('kfc_burger_02', 'kfc', '타워버거', 'burger', 7500, 560, None, '인기'),
    ('kfc_burger_03', 'kfc', '치킨필렛버거', 'burger', 5500, 420, None, '가성비'),
    ('kfc_burger_04', 'kfc', '불고기버거', 'burger', 5000, 390, None, '가성비'),
    ('kfc_burger_05', 'kfc', '더블다운맥스', 'burger', 8900, 650, None, '프리미엄'),
    # Sides
    ('kfc_side_01', 'kfc', '핫크리스피치킨 1조각', 'side', 3200, 290, None, '시그니처,인기'),
    ('kfc_side_02', 'kfc', '핫크리스피치킨 2조각', 'side', 5800, 580, None, '시그니처'),
    ('kfc_side_03', 'kfc', '코울슬로', 'side', 2000, 180, None, ''),
    ('kfc_side_04', 'kfc', '비스켓', 'side', 1800, 240, None, ''),
    ('kfc_side_05', 'kfc', '프렌치프라이 (M)', 'side', 2500, 340, None, ''),
    # Drinks
    ('kfc_drink_01', 'kfc', '코카콜라 (M)', 'drink', 2100, 150, None, ''),
    ('kfc_drink_02', 'kfc', '아메리카노', 'drink', 2500, 10, None, ''),
    ('kfc_drink_03', 'kfc', '커널스위트콘샐러드', 'drink', 2000, 100, None, ''),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Mom's Touch (mom)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mom_burger_01', 'mom', '싸이버거', 'burger', 4900, 480, None, '시그니처,인기,가성비'),
    ('mom_burger_02', 'mom', '불싸이버거', 'burger', 5500, 520, None, '매운,인기'),
    ('mom_burger_03', 'mom', '인크레더블버거', 'burger', 6900, 590, None, '프리미엄'),
    ('mom_burger_04', 'mom', '치즈불싸이버거', 'burger', 6200, 560, None, '매운'),
    ('mom_burger_05', 'mom', '흑미새우버거', 'burger', 5200, 420, None, ''),
    ('mom_burger_06', 'mom', '딥치즈버거', 'burger', 5800, 510, None, ''),
    # Sides
    ('mom_side_01', 'mom', '후라이드치킨 1조각', 'side', 2000, 280, None, '가성비'),
    ('mom_side_02', 'mom', '양념치킨 1조각', 'side', 2200, 300, None, ''),
    ('mom_side_03', 'mom', '감자튀김 (M)', 'side', 2500, 340, None, ''),
    ('mom_side_04', 'mom', '치즈스틱 3조각', 'side', 2800, 260, None, ''),
    # Drinks
    ('mom_drink_01', 'mom', '코카콜라 (M)', 'drink', 1800, 150, None, ''),
    ('mom_drink_02', 'mom', '아메리카노', 'drink', 2000, 10, None, ''),
    ('mom_drink_03', 'mom', '레모네이드', 'drink', 2500, 120, None, ''),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Lotteria (lot)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('lot_burger_01', 'lot', '불고기버거', 'burger', 4500, 400, None, '시그니처,인기,가성비'),
    ('lot_burger_02', 'lot', 'AZ버거', 'burger', 6200, 520, None, '인기'),
    ('lot_burger_03', 'lot', '한우불고기버거', 'burger', 6900, 530, None, '프리미엄'),
    ('lot_burger_04', 'lot', '새우버거', 'burger', 5500, 410, None, ''),
    ('lot_burger_05', 'lot', '모짜렐라인더버거', 'burger', 7200, 580, None, '프리미엄'),
    ('lot_burger_06', 'lot', '리아 불고기', 'burger', 5000, 420, None, '가성비'),
    ('lot_burger_07', 'lot', '데리버거', 'burger', 3800, 380, None, '가성비'),
    # Sides
    ('lot_side_01', 'lot', '양념감자', 'side', 2500, 300, None, '인기'),
    ('lot_side_02', 'lot', '어니언링', 'side', 2800, 310, None, ''),
    ('lot_side_03', 'lot', '치즈스틱', 'side', 3000, 270, None, ''),
    ('lot_side_04', 'lot', '프렌치프라이 (M)', 'side', 2500, 330, None, ''),
    # Drinks
    ('lot_drink_01', 'lot', '코카콜라 (M)', 'drink', 2000, 150, None, ''),
    ('lot_drink_02', 'lot', '아메리카노', 'drink', 2300, 10, None, ''),
    ('lot_drink_03', 'lot', '밀크쉐이크', 'drink', 3300, 480, None, ''),
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
            type      TEXT NOT NULL CHECK(type IN ('burger','side','drink','set')),
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
