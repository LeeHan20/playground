import pyautogui
import time

def get_mouse_position():
    print("마우스를 원하는 위치로 이동하고 클릭하세요...")
    x, y = pyautogui.position()
    print(f"현재 마우스 위치: x={x}, y={y}")
    return x, y

def click_and_enter(x, y, interval=1):
    try:
        while True:
            pyautogui.click(x, y)  # 지정한 위치를 클릭
            time.sleep(interval)  # 인터벌
            pyautogui.press('enter')  # 엔터 키를 누름
            time.sleep(interval)  # 인터벌
    except KeyboardInterrupt:
        print("매크로가 중지되었습니다.")

if __name__ == "__main__":
    print("매크로를 설정하기 위해 마우스 위치를 지정하세요.")
    
    # 마우스 포인터의 위치를 확인하기 위해 클릭 대기
    input("위치를 설정한 후 Enter를 눌러 주세요...")
    x, y = pyautogui.position()
    print(f"지정된 위치: x={x}, y={y}")

    interval = float(input("클릭 간격(초)을 입력하세요: "))

    print("매크로를 시작합니다. 중지하려면 Ctrl+C를 누르세요.")
    click_and_enter(x, y, interval)

#사용방법

#위 코드를 macro.py로 저장해줍니다
#터미널을 열어서 pip3 install pyautogui로 파이오토gui를 설치해줍니다
#터미널에서 pwd, ls를 입력하여 macro.py 파일이 어디에 있는지 확인합니다
#터미널에서 확인하기 귀찮다면 finder에서 직접 찾아서 다운로드, 문서 등 어디에 있는지 확인합니다
#터미널에 cd ~/path/to/your/macro/file을 입력합니다
#여기서 cd ~가 필수이고 만약 macro파일이 Downloads에 있다면 cd ~/Downloads를 입력해줍니다
#python3 macro.py를 입력하여 macro파일을 실행해주고 파일이 지시하는 단계에 따릅니다
#
