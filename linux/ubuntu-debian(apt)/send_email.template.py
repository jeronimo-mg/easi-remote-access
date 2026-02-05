import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# --- CONFIGURAÇÃO (PREENCHA AQUI) ---
SMTP_SERVER = "smtp.gmail.com" # Ex: smtp.gmail.com, smtp-mail.outlook.com
SMTP_PORT = 587
SENDER_EMAIL = "seu_email@gmail.com"
SENDER_PASSWORD = "sua_senha_de_aplicativo" # NÃO use sua senha normal, crie uma "App Password"
RECEIVER_EMAIL = "email_destino@gmail.com"
# ------------------------------------

def send_email(url):
    subject = "ClickTop: Novo Link de Acesso Remoto"
    body = f"""Olá!

O seu computador iniciou o acesso remoto.
Aqui está o seu novo link de acesso:

{url}

Este link é válido enquanto o computador estiver ligado.
"""

    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, text)
        server.quit()
        print("E-mail enviado com sucesso!")
    except Exception as e:
        print(f"Erro ao enviar e-mail: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 send_email.py <URL>")
    else:
        url = sys.argv[1]
        send_email(url)
