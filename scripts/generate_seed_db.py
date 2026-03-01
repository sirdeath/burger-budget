#!/usr/bin/env python3
"""
Burger Budget - Seed DB Generator

5개 프랜차이즈(맥도날드, 버거킹, KFC, 맘스터치, 롯데리아)의
메뉴 데이터를 SQLite DB로 생성합니다.

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
# (id, franchise, name, type, price, price_delivery, price_updated_at,
#  calories, imageUrl, tags, includes_side, includes_drink)
#
# Data source: .claude/price-collection/price-summary.md
# price = 매장가격 (공식앱 매장주문 기준)
# price_delivery = 배달가격 (None이면 배달 정보 없음)
#   맥도날드/버거킹/KFC/롯데리아 → 공식앱 배달주문
#   맘스터치 → 배달의민족(배민) (공식앱은 매장=배달 동일가)

MENUS = [
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # McDonald's (mcd) — 2026-02-28 수집
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mcd_burger_01', 'mcd', '빅맥', 'burger', 5700, 6600, '2026-02-28', 582, None, '시그니처,인기', 0, 0),
    ('mcd_burger_02', 'mcd', '맥스파이시 상하이 버거', 'burger', 5900, 6800, '2026-02-28', 464, None, '매운,인기', 0, 0),
    ('mcd_burger_03', 'mcd', '1955 버거', 'burger', 6700, 7600, '2026-02-28', 530, None, '프리미엄', 0, 0),
    ('mcd_burger_04', 'mcd', '베이컨 토마토 디럭스', 'burger', 5800, 6700, '2026-02-28', 542, None, '', 0, 0),
    ('mcd_burger_05', 'mcd', '쿼터파운더 치즈', 'burger', 5900, 6800, '2026-02-28', 517, None, '시그니처', 0, 0),
    ('mcd_burger_06', 'mcd', '더블 쿼터파운더 치즈', 'burger', 7700, 8600, '2026-02-28', 733, None, '프리미엄', 0, 0),
    ('mcd_burger_07', 'mcd', '불고기 버거', 'burger', 3800, 4700, '2026-02-28', 383, None, '가성비', 0, 0),
    ('mcd_burger_08', 'mcd', '더블 불고기 버거', 'burger', 4700, 5600, '2026-02-28', 583, None, '', 0, 0),
    ('mcd_burger_09', 'mcd', '슈비 버거', 'burger', 6200, 7100, '2026-02-28', 548, None, '인기', 0, 0),
    ('mcd_burger_10', 'mcd', '슈슈 버거', 'burger', 4700, 5600, '2026-02-28', 424, None, '', 0, 0),
    ('mcd_burger_11', 'mcd', '맥치킨 모짜렐라', 'burger', 5000, 5900, '2026-02-28', 670, None, '인기', 0, 0),
    ('mcd_burger_12', 'mcd', '맥치킨', 'burger', 3500, 4400, '2026-02-28', 482, None, '가성비', 0, 0),
    ('mcd_burger_13', 'mcd', '트리플 치즈 버거', 'burger', 6100, 7000, '2026-02-28', 619, None, '프리미엄', 0, 0),
    # Sides
    ('mcd_side_01', 'mcd', '후렌치 후라이 (M)', 'side', 2600, 3500, '2026-02-28', 320, None, '인기', 0, 0),
    ('mcd_side_02', 'mcd', '후렌치 후라이 (L)', 'side', 3200, None, '2026-02-28', 400, None, '', 0, 0),
    ('mcd_side_03', 'mcd', '맥너겟 6조각', 'side', 4100, 5000, '2026-02-28', 270, None, '인기', 0, 0),
    ('mcd_side_04', 'mcd', '맥윙 4조각', 'side', 6900, 7800, '2026-02-28', 380, None, '', 0, 0),
    ('mcd_side_05', 'mcd', '황금 모짜렐라 치즈스틱 4조각', 'side', 4500, 5400, '2026-02-28', 340, None, '', 0, 0),
    ('mcd_side_06', 'mcd', '코울슬로', 'side', 2000, 2900, '2026-02-28', 80, None, '', 0, 0),
    ('mcd_side_07', 'mcd', '상하이 치킨 스낵랩', 'side', 3500, 4400, '2026-02-28', 290, None, '', 0, 0),
    # Drinks
    ('mcd_drink_01', 'mcd', '탄산음료 (M)', 'drink', 2000, 2800, '2026-02-28', 140, None, '', 0, 0),
    ('mcd_drink_02', 'mcd', '탄산음료 (L)', 'drink', 2400, None, '2026-02-28', 180, None, '', 0, 0),
    ('mcd_drink_03', 'mcd', '밀크쉐이크', 'drink', 2800, 3600, '2026-02-28', 370, None, '', 0, 0),
    ('mcd_drink_04', 'mcd', '아이스 드립 커피', 'drink', 2000, 3200, '2026-02-28', 5, None, '', 0, 0),
    ('mcd_drink_05', 'mcd', '복숭아 아이스티', 'drink', 3100, 3900, '2026-02-28', 120, None, '', 0, 0),
    # Desserts
    ('mcd_dessert_01', 'mcd', '소프트 아이스크림 콘', 'dessert', 1500, None, '2026-02-28', 150, None, '가성비', 0, 0),
    ('mcd_dessert_02', 'mcd', '맥플러리 (오레오)', 'dessert', 3600, 4400, '2026-02-28', 340, None, '인기', 0, 0),
    ('mcd_dessert_03', 'mcd', '바닐라 선데', 'dessert', 2200, None, '2026-02-28', 220, None, '', 0, 0),
    ('mcd_dessert_04', 'mcd', '애플 파이', 'dessert', 1500, None, '2026-02-28', 240, None, '가성비', 0, 0),
    ('mcd_dessert_05', 'mcd', '츄러스 3개', 'dessert', 2500, 3300, '2026-02-28', 280, None, '', 0, 0),
    # Sets
    ('mcd_set_01', 'mcd', '빅맥 세트', 'set', 7600, 9000, '2026-02-28', 1000, None, '시그니처,인기', 1, 1),
    ('mcd_set_02', 'mcd', '맥스파이시 상하이 버거 세트', 'set', 7700, 9100, '2026-02-28', 950, None, '매운,인기', 1, 1),
    ('mcd_set_03', 'mcd', '1955 버거 세트', 'set', 8400, 9800, '2026-02-28', 1010, None, '프리미엄', 1, 1),
    ('mcd_set_04', 'mcd', '쿼터파운더 치즈 세트', 'set', 7900, 9300, '2026-02-28', 990, None, '시그니처', 1, 1),
    ('mcd_set_05', 'mcd', '슈비 버거 세트', 'set', 8500, 9900, '2026-02-28', 1020, None, '인기', 1, 1),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burger King (bk) — 2026-03-01 수집
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('bk_burger_01', 'bk', '와퍼', 'burger', 7400, 8400, '2026-03-01', 699, None, '시그니처,인기', 0, 0),
    ('bk_burger_02', 'bk', '불고기 와퍼', 'burger', 7400, 8400, '2026-03-01', 690, None, '', 0, 0),
    ('bk_burger_03', 'bk', '치즈 와퍼', 'burger', 8000, 9000, '2026-03-01', 716, None, '인기', 0, 0),
    ('bk_burger_04', 'bk', '베이컨 치즈 와퍼', 'burger', 9200, 10200, '2026-03-01', 780, None, '프리미엄', 0, 0),
    ('bk_burger_05', 'bk', '통새우 와퍼', 'burger', 8200, 9200, '2026-03-01', 741, None, '인기', 0, 0),
    ('bk_burger_06', 'bk', '콰트로 치즈 와퍼', 'burger', 8200, 9200, '2026-03-01', 769, None, '프리미엄', 0, 0),
    ('bk_burger_07', 'bk', '몬스터 와퍼', 'burger', 9600, 10600, '2026-03-01', 1055, None, '프리미엄', 0, 0),
    ('bk_burger_08', 'bk', '와퍼 주니어', 'burger', 5000, 6000, '2026-03-01', 390, None, '가성비', 0, 0),
    ('bk_burger_09', 'bk', '치즈버거', 'burger', 3800, 4800, '2026-03-01', 366, None, '가성비', 0, 0),
    ('bk_burger_10', 'bk', '비프불고기 버거', 'burger', 4300, 5300, '2026-03-01', 457, None, '', 0, 0),
    ('bk_burger_11', 'bk', '더블 비프불고기 버거', 'burger', 5300, 6300, '2026-03-01', 588, None, '', 0, 0),
    ('bk_burger_12', 'bk', '치킨버거', 'burger', 4000, 5000, '2026-03-01', 523, None, '가성비', 0, 0),
    ('bk_burger_13', 'bk', '롱치킨 버거', 'burger', 4700, None, '2026-03-01', 571, None, '', 0, 0),
    ('bk_burger_14', 'bk', '슈림프 버거', 'burger', 5900, None, '2026-03-01', 439, None, '', 0, 0),
    ('bk_burger_15', 'bk', '통새우 슈림프 버거', 'burger', 6300, 7300, '2026-03-01', 516, None, '인기', 0, 0),
    ('bk_burger_16', 'bk', '치킨킹', 'burger', 6700, 7800, '2026-03-01', 691, None, '인기', 0, 0),
    # Sides
    ('bk_side_01', 'bk', '프렌치프라이 (레귤러)', 'side', 2300, 3300, '2026-03-01', 310, None, '', 0, 0),
    ('bk_side_02', 'bk', '프렌치프라이 (라지)', 'side', 2800, 3800, '2026-03-01', 370, None, '', 0, 0),
    ('bk_side_03', 'bk', '너겟킹 4조각', 'side', 2300, 3300, '2026-03-01', 190, None, '', 0, 0),
    ('bk_side_04', 'bk', '너겟킹 8조각', 'side', 4500, 5500, '2026-03-01', 368, None, '', 0, 0),
    ('bk_side_05', 'bk', '어니언링', 'side', 2800, 3800, '2026-03-01', 280, None, '인기', 0, 0),
    ('bk_side_06', 'bk', '21 치즈스틱', 'side', 2600, 3600, '2026-03-01', 200, None, '', 0, 0),
    ('bk_side_07', 'bk', '코울슬로', 'side', 2300, 3300, '2026-03-01', 110, None, '', 0, 0),
    ('bk_side_08', 'bk', '콘샐러드', 'side', 2300, 3300, '2026-03-01', 130, None, '', 0, 0),
    # Drinks
    ('bk_drink_01', 'bk', '탄산음료 (레귤러)', 'drink', 2200, 3200, '2026-03-01', 140, None, '', 0, 0),
    ('bk_drink_02', 'bk', '탄산음료 (라지)', 'drink', 2400, 3400, '2026-03-01', 180, None, '', 0, 0),
    ('bk_drink_03', 'bk', '아메리카노', 'drink', 1600, 2600, '2026-03-01', 5, None, '', 0, 0),
    ('bk_drink_04', 'bk', '미닛메이드 오렌지', 'drink', 2800, None, '2026-03-01', 150, None, '', 0, 0),
    # Desserts
    ('bk_dessert_01', 'bk', '선데 아이스크림', 'dessert', 2200, None, '2026-03-01', 230, None, '인기', 0, 0),
    ('bk_dessert_02', 'bk', '킹퓨전', 'dessert', 3500, None, '2026-03-01', 320, None, '', 0, 0),
    ('bk_dessert_03', 'bk', '컵 아이스크림', 'dessert', 900, None, '2026-03-01', 90, None, '가성비', 0, 0),
    # Sets
    ('bk_set_01', 'bk', '와퍼 세트', 'set', 9600, 11100, '2026-03-01', 1170, None, '시그니처,인기', 1, 1),
    ('bk_set_02', 'bk', '불고기 와퍼 세트', 'set', 9600, 11100, '2026-03-01', 1160, None, '', 1, 1),
    ('bk_set_03', 'bk', '치즈 와퍼 세트', 'set', 10200, 11700, '2026-03-01', 1190, None, '인기', 1, 1),
    ('bk_set_04', 'bk', '몬스터 와퍼 세트', 'set', 11300, 12800, '2026-03-01', 1520, None, '프리미엄', 1, 1),
    ('bk_set_05', 'bk', '치킨킹 세트', 'set', 8900, 10500, '2026-03-01', 1160, None, '인기', 1, 1),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # KFC (kfc) — 2026-02-28 수집
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('kfc_burger_01', 'kfc', '징거버거', 'burger', 5900, 6200, '2026-02-28', 553, None, '시그니처,인기', 0, 0),
    ('kfc_burger_02', 'kfc', '징거타워버거', 'burger', 6900, 7200, '2026-02-28', 680, None, '인기', 0, 0),
    ('kfc_burger_03', 'kfc', '징거BLT버거', 'burger', 7100, 7400, '2026-02-28', 720, None, '프리미엄', 0, 0),
    ('kfc_burger_04', 'kfc', '트위스터', 'burger', 4200, 4500, '2026-02-28', 430, None, '', 0, 0),
    ('kfc_burger_05', 'kfc', '커넬 오리지널 버거', 'burger', 4200, None, '2026-02-28', 380, None, '가성비', 0, 0),
    ('kfc_burger_06', 'kfc', '커넬 데리야끼 버거', 'burger', 4500, None, '2026-02-28', 420, None, '', 0, 0),
    ('kfc_burger_07', 'kfc', '클래식 징거 통다리버거', 'burger', 6400, 6700, '2026-02-28', 640, None, '인기', 0, 0),
    # Sides
    ('kfc_side_01', 'kfc', '핫크리스피 치킨 1조각', 'side', 3400, 3500, '2026-02-28', 290, None, '시그니처,인기', 0, 0),
    ('kfc_side_02', 'kfc', '오리지널 치킨 1조각', 'side', 3300, 3400, '2026-02-28', 260, None, '시그니처', 0, 0),
    ('kfc_side_03', 'kfc', '갓양념치킨 1조각', 'side', 3500, 3600, '2026-02-28', 310, None, '인기', 0, 0),
    ('kfc_side_04', 'kfc', '텐더 2조각', 'side', 3200, 3300, '2026-02-28', 240, None, '', 0, 0),
    ('kfc_side_05', 'kfc', '프렌치프라이 (M)', 'side', 2300, 2500, '2026-02-28', 320, None, '', 0, 0),
    ('kfc_side_06', 'kfc', '프렌치프라이 (L)', 'side', 2800, 3000, '2026-02-28', 400, None, '', 0, 0),
    ('kfc_side_07', 'kfc', '버터비스켓', 'side', 2600, 2700, '2026-02-28', 280, None, '', 0, 0),
    ('kfc_side_08', 'kfc', '콘샐러드', 'side', 2300, None, '2026-02-28', 130, None, '', 0, 0),
    ('kfc_side_09', 'kfc', '코울슬로', 'side', 2100, 2300, '2026-02-28', 110, None, '', 0, 0),
    # Drinks
    ('kfc_drink_01', 'kfc', '콜라/스프라이트 (M)', 'drink', 2200, 2500, '2026-02-28', 140, None, '', 0, 0),
    ('kfc_drink_02', 'kfc', '콜라/스프라이트 (L)', 'drink', 2400, 2700, '2026-02-28', 180, None, '', 0, 0),
    # Desserts
    ('kfc_dessert_01', 'kfc', '에그타르트', 'dessert', 2300, 2400, '2026-02-28', 230, None, '인기', 0, 0),
    # Sets
    ('kfc_set_01', 'kfc', '징거버거 세트', 'set', 7900, 8400, '2026-02-28', 1030, None, '시그니처,인기', 1, 1),
    ('kfc_set_02', 'kfc', '징거타워버거 세트', 'set', 8900, 9400, '2026-02-28', 1160, None, '인기', 1, 1),
    ('kfc_set_03', 'kfc', '징거BLT버거 세트', 'set', 9100, 9600, '2026-02-28', 1200, None, '프리미엄', 1, 1),
    ('kfc_set_04', 'kfc', '클래식 징거 통다리버거 세트', 'set', 8400, 8900, '2026-02-28', 1110, None, '인기', 1, 1),
    ('kfc_set_05', 'kfc', '커넬 오리지널 버거 세트', 'set', 6400, None, '2026-02-28', 860, None, '가성비', 1, 1),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Mom's Touch (mom) — 2026-03-01 수집
    # 배달가격 출처: 배달의민족 (공식앱은 매장=배달 동일가)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('mom_burger_01', 'mom', '싸이버거', 'burger', 5200, 6200, '2026-03-01', 594, None, '시그니처,인기,가성비', 0, 0),
    ('mom_burger_02', 'mom', '불싸이버거', 'burger', 5400, 6400, '2026-03-01', 620, None, '매운,인기', 0, 0),
    ('mom_burger_03', 'mom', '화이트갈릭 싸이버거', 'burger', 5800, 6800, '2026-03-01', 650, None, '인기', 0, 0),
    ('mom_burger_04', 'mom', '딥치즈 싸이버거', 'burger', 5700, 6700, '2026-03-01', 660, None, '', 0, 0),
    ('mom_burger_05', 'mom', '휠렛버거', 'burger', 5000, 6000, '2026-03-01', 500, None, '', 0, 0),
    ('mom_burger_06', 'mom', '화이트갈릭 버거', 'burger', 5500, 6500, '2026-03-01', 530, None, '', 0, 0),
    ('mom_burger_07', 'mom', '그릴드비프 버거', 'burger', 5400, None, '2026-03-01', 510, None, '', 0, 0),
    ('mom_burger_08', 'mom', '불고기버거', 'burger', 4200, 5200, '2026-03-01', 430, None, '가성비', 0, 0),
    ('mom_burger_09', 'mom', '통새우버거', 'burger', 4100, 5100, '2026-03-01', 380, None, '가성비', 0, 0),
    # Sides
    ('mom_side_01', 'mom', '케이준 양념감자 (S)', 'side', 2100, 2900, '2026-03-01', 349, None, '인기', 0, 0),
    ('mom_side_02', 'mom', '케이준 양념감자 (M)', 'side', 3600, 4600, '2026-03-01', 490, None, '인기', 0, 0),
    ('mom_side_03', 'mom', '치즈스틱', 'side', 2100, 2900, '2026-03-01', 230, None, '', 0, 0),
    ('mom_side_04', 'mom', '할라피뇨 너겟 4조각', 'side', 2100, 2900, '2026-03-01', 200, None, '매운', 0, 0),
    # Drinks
    ('mom_drink_01', 'mom', '콜라/사이다 (355ml)', 'drink', 1600, None, '2026-03-01', 140, None, '', 0, 0),
    ('mom_drink_02', 'mom', '콜라/사이다 (500ml PET)', 'drink', 2000, None, '2026-03-01', 200, None, '', 0, 0),
    # Sets
    ('mom_set_01', 'mom', '싸이버거 세트', 'set', 7700, 9200, '2026-03-01', 1043, None, '시그니처,인기,가성비', 1, 1),
    ('mom_set_02', 'mom', '불싸이버거 세트', 'set', 7900, 9400, '2026-03-01', 1100, None, '매운,인기', 1, 1),
    ('mom_set_03', 'mom', '화이트갈릭 싸이버거 세트', 'set', 8300, 9800, '2026-03-01', 1150, None, '인기', 1, 1),
    ('mom_set_04', 'mom', '딥치즈 싸이버거 세트', 'set', 8200, 9700, '2026-03-01', 1140, None, '', 1, 1),
    ('mom_set_05', 'mom', '휠렛버거 세트', 'set', 7500, 9000, '2026-03-01', 1020, None, '', 1, 1),
    ('mom_set_06', 'mom', '불고기버거 세트', 'set', 6700, 8200, '2026-03-01', 920, None, '가성비', 1, 1),

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Lotteria (lot) — 2026-03-01 수집
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Burgers
    ('lot_burger_01', 'lot', '리아 불고기', 'burger', 5000, 5800, '2026-03-01', 462, None, '시그니처,인기', 0, 0),
    ('lot_burger_02', 'lot', '리아 새우', 'burger', 5000, 5800, '2026-03-01', 420, None, '인기', 0, 0),
    ('lot_burger_03', 'lot', '클래식 치즈버거', 'burger', 5500, 6300, '2026-03-01', 510, None, '', 0, 0),
    ('lot_burger_04', 'lot', '데리버거', 'burger', 3700, 4500, '2026-03-01', 360, None, '가성비', 0, 0),
    ('lot_burger_05', 'lot', '치킨버거', 'burger', 4300, 5100, '2026-03-01', 355, None, '가성비', 0, 0),
    ('lot_burger_06', 'lot', '한우불고기 버거', 'burger', 9000, 9800, '2026-03-01', 572, None, '프리미엄', 0, 0),
    ('lot_burger_07', 'lot', 'NEW 미라클버거', 'burger', 5700, 6500, '2026-03-01', 382, None, '', 0, 0),
    # Sides
    ('lot_side_01', 'lot', '포테이토 (R)', 'side', 2000, 2800, '2026-03-01', 284, None, '가성비', 0, 0),
    ('lot_side_02', 'lot', '포테이토 (L)', 'side', 2500, 3300, '2026-03-01', 355, None, '', 0, 0),
    ('lot_side_03', 'lot', '양념감자', 'side', 2600, 3400, '2026-03-01', 369, None, '인기', 0, 0),
    ('lot_side_04', 'lot', '치즈스틱', 'side', 2800, 3600, '2026-03-01', 158, None, '', 0, 0),
    ('lot_side_05', 'lot', '통오징어링', 'side', 2800, 3600, '2026-03-01', 166, None, '', 0, 0),
    ('lot_side_06', 'lot', '지파이', 'side', 1800, None, '2026-03-01', 397, None, '가성비', 0, 0),
    # Drinks
    ('lot_drink_01', 'lot', '펩시콜라 (M)', 'drink', 2000, 2700, '2026-03-01', 128, None, '', 0, 0),
    ('lot_drink_02', 'lot', '펩시콜라 (L)', 'drink', 2200, 2900, '2026-03-01', 174, None, '', 0, 0),
    ('lot_drink_03', 'lot', '아메리카노', 'drink', 2500, 3200, '2026-03-01', 8, None, '', 0, 0),
    ('lot_drink_04', 'lot', '아이스티', 'drink', 2300, 3000, '2026-03-01', 160, None, '', 0, 0),
    # Desserts
    ('lot_dessert_01', 'lot', '소프트콘', 'dessert', 1300, None, '2026-03-01', 120, None, '가성비', 0, 0),
    ('lot_dessert_02', 'lot', '선데 아이스크림', 'dessert', 2100, None, '2026-03-01', 210, None, '인기', 0, 0),
    # Sets
    ('lot_set_01', 'lot', '리아 불고기 세트', 'set', 7300, 8600, '2026-03-01', 870, None, '시그니처,인기', 1, 1),
    ('lot_set_02', 'lot', '리아 새우 세트', 'set', 7300, 8600, '2026-03-01', 830, None, '인기', 1, 1),
    ('lot_set_03', 'lot', '클래식 치즈버거 세트', 'set', 7700, 9000, '2026-03-01', 920, None, '', 1, 1),
    ('lot_set_04', 'lot', '데리버거 세트', 'set', 6100, 7400, '2026-03-01', 760, None, '가성비', 1, 1),
    ('lot_set_05', 'lot', '치킨버거 세트', 'set', 6700, 8000, '2026-03-01', 750, None, '가성비', 1, 1),
    ('lot_set_06', 'lot', '한우불고기 버거 세트', 'set', 10900, 12200, '2026-03-01', 1000, None, '프리미엄', 1, 1),
]


def generate_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE menus (
            id            TEXT PRIMARY KEY,
            franchise     TEXT NOT NULL,
            name          TEXT NOT NULL,
            type          TEXT NOT NULL CHECK(type IN ('burger','side','drink','set','dessert')),
            price         INTEGER NOT NULL,
            price_delivery INTEGER,
            price_updated_at TEXT DEFAULT '2026-02-24',
            calories      INTEGER,
            imageUrl      TEXT,
            tags          TEXT DEFAULT '',
            includes_side INTEGER NOT NULL DEFAULT 0,
            includes_drink INTEGER NOT NULL DEFAULT 0
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
        'INSERT INTO menus (id, franchise, name, type, price, price_delivery, price_updated_at, '
        'calories, imageUrl, tags, includes_side, includes_drink) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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

    cursor.execute(
        'SELECT COUNT(*) FROM menus WHERE price_delivery IS NOT NULL'
    )
    with_delivery = cursor.fetchone()[0]

    conn.close()

    print(f'Seed DB generated: {DB_PATH}')
    print(f'Total items: {total}')
    print(f'With delivery price: {with_delivery}')
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
