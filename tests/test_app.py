import pytest
from app import app


@pytest.fixture
def client():
    """Создаем тестовый клиент Flask"""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health_check(client):
    """Проверяем, что эндпоинт /health возвращает статус ok"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json == {"status": "ok"}


def test_home_page_load(client):
    """Проверяем, что главная страница открывается (GET запрос)"""
    response = client.get("/")
    assert response.status_code == 200
    # Проверяем, что в ответе есть заголовок из твоего HTML
    assert b"Simple Flask Calculator" in response.data


def test_addition(client):
    """Тест сложения: 10 + 5 = 15"""
    response = client.post("/", data={"num1": "10", "num2": "5", "operation": "add"})
    assert response.status_code == 200
    # Flask возвращает байты, поэтому ищем байтовую строку b'...'
    assert b"Result: 15.0" in response.data


def test_subtraction(client):
    """Тест вычитания: 10 - 4 = 6"""
    response = client.post("/", data={"num1": "10", "num2": "4", "operation": "sub"})
    assert b"Result: 6.0" in response.data


def test_multiplication(client):
    """Тест умножения: 3 * 3 = 9"""
    response = client.post("/", data={"num1": "3", "num2": "3", "operation": "mul"})
    assert b"Result: 9.0" in response.data


def test_division(client):
    """Тест деления: 10 / 2 = 5"""
    response = client.post("/", data={"num1": "10", "num2": "2", "operation": "div"})
    assert b"Result: 5.0" in response.data


def test_division_by_zero(client):
    """Тест деления на ноль (должна быть ошибка)"""
    response = client.post("/", data={"num1": "5", "num2": "0", "operation": "div"})
    assert b"Cannot divide by zero" in response.data


def test_invalid_input(client):
    """Тест отправки текста вместо цифр"""
    response = client.post(
        "/", data={"num1": "abc", "num2": "5", "operation": "add"}  # Не число
    )
    # Твой код ловит ValueError при попытке float('abc')
    assert b"Error" in response.data
    assert b"could not convert string to float" in response.data
