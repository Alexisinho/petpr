from flask import Flask, request, render_template_string, jsonify

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Flask Calculator</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 50px; }
    input, select, button { margin: 5px; padding: 5px; }
  </style>
</head>
<body>
  <h2>🧮 Simple Flask Calculator</h2>
  <form method="POST">
    <input type="number" name="num1" step="any" required>
    <select name="operation">
      <option value="add">+</option>
      <option value="sub">−</option>
      <option value="mul">×</option>
      <option value="div">÷</option>
    </select>
    <input type="number" name="num2" step="any" required>
    <button type="submit">Calculate</button>
  </form>

  {% if result is not none %}
    <h3>✅ Result: {{ result }}</h3>
  {% endif %}
  {% if error %}
    <p style="color: red;">{{ error }}</p>
  {% endif %}
</body>
</html>
"""


@app.route("/", methods=["GET", "POST"])
def index():
    result = None
    error = None
    if request.method == "POST":
        try:
            num1 = float(request.form["num1"])
            num2 = float(request.form["num2"])
            op = request.form["operation"]
            if op == "add":
                result = num1 + num2
            elif op == "sub":
                result = num1 - num2
            elif op == "mul":
                result = num1 * num2
            elif op == "div":
                result = num1 / num2
            else:
                error = "Unknown operation"
        except Exception as e:
            error = f"Error: {e}"
    return render_template_string(HTML, result=result, error=error)


@app.route("/health")
def health():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
    