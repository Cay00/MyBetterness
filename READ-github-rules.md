# 📌 Workflow pracy z GitHub

## 1. Tworzenie Issue

Każda nowa funkcja, poprawka błędu lub zmiana powinna mieć własne **Issue** w GitHub.

**Issue powinno zawierać:**
- krótki tytuł  
- opis zadania  
- ewentualne wymagania  

**Przykład:**

```
Title: Add Firebase authentication
Description: Implement login with Firebase.
```

---

## 2. Tworzenie brancha

Nowe zmiany wykonujemy zawsze na osobnym branchu — **nigdy bezpośrednio na `main`**.

Branch tworzymy od aktualnego `main`, **przed wprowadzeniem jakichkolwiek zmian**.

**Schemat nazw:**
- `feature/nazwa-funkcji`
- `fix/nazwa-błędu`
- `chore/dodatek-funkcji`

Jeśli branch jest powiązany z Issue, dodajemy jego numer.

**Przykłady:**

```
feature/12-firebase-auth
fix/15-login-error
```

---

## 3. Wprowadzanie zmian

Po utworzeniu brancha:

```bash
git checkout -b feature/12-firebase-auth
```

Po wprowadzeniu zmian:

```bash
git add .
git commit -m "Add Firebase authentication"
git push origin feature/12-firebase-auth
```

---

## 4. Tworzenie Pull Request (PR)

Po wypchnięciu brancha tworzymy **Pull Request** w GitHub.

**PR powinien zawierać:**

**Tytuł:**
```
Add Firebase authentication
```

**Opis:**
```
Closes #12
Implemented Firebase login functionality.
```

> `Closes #12` automatycznie zamknie Issue po mergu.

---

## 5. Review i Approval

Każdy PR musi zostać sprawdzony przez co najmniej jedną osobę z zespołu.

**Reviewer sprawdza:**
- poprawność kodu  
- czy funkcja działa  
- czy nie powoduje konfliktów  

**Decyzje:**
- `Approve` – jeśli wszystko jest poprawne  
- `Request changes` – jeśli wymagane są poprawki  
