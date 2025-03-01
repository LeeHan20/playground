import tkinter as tk
from tkinter import messagebox
import random
import csv
import os

INITIAL_CHIPS = 500

class BlackjackGame:
    def update_result(self, initial=False):
        player_value = self.calculate_hand_value(self.player_hand)
        dealer_value = self.calculate_hand_value(self.dealer_hand)

        if initial:
            result_text = f"딜러의 카드: {self.dealer_hand[1]}와 ?\n당신의 카드: {' '.join(map(str, self.player_hand))} (값: {player_value})\n"
        else:
            result_text = f"딜러의 카드: {self.dealer_hand[1]}와 ?\n당신의 카드: {' '.join(map(str, self.player_hand))} (값: {player_value})\n"

        if initial:
            self.result_label.config(text=result_text)
            return

        if player_value > 21:
            self.end_game(f"플레이어의 버스트! 욕심을 조금 버려야겠어요 하하!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=-self.bet)
        elif player_value == 21 and len(self.player_hand) == 2:
            self.end_game("블랙잭! 운이 좋네요", chips_changed=self.bet * 2)
        elif dealer_value > 21:
            self.end_game(f"딜러의 버스트! 운이 좋았네요!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=self.bet)
        elif player_value == dealer_value:
            self.end_game(f"무승부입니다!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=0)
        else:
            self.result_label.config(text=result_text)

        if player_value <= 21:
            self.hit_button.config(state=tk.NORMAL)
            self.stand_button.config(state=tk.NORMAL)

        if dealer_value < 17:
            self.hit_button.config(state=tk.DISABLED)
            self.stand_button.config(state=tk.DISABLED)
            self.dealer_hit()

    def dealer_hit(self):
        self.dealer_hand.append(self.deck.pop())
        self.update_result()

    def __init__(self, root):
        self.root = root
        self.root.title("블랙잭 게임")

        self.balance = 0
        self.bet = 0
        self.deck = []
        self.player_hand = []
        self.dealer_hand = []

        self.user_data = {}
        self.load_user_data()

        self.current_user = None
        self.games_played = 0
        self.games_won = 0

        self.create_login_screen()

    def create_deck(self):
        values = list(range(2, 11)) + ['J', 'Q', 'K', 'A']
        suits = ['하트', '다이아몬드', '클로버', '스페이드']
        deck = [(str(value), suit) for value in values for suit in suits]
        random.shuffle(deck)
        return deck

    def calculate_hand_value(self, hand):
        value = 0
        aces = 0
        for card, suit in hand:
            if card in ['J', 'Q', 'K']:
                value += 10
            elif card == 'A':
                aces += 1
                value += 11
            else:
                value += int(card)

        while value > 21 and aces:
            value -= 10
            aces -= 1

        return value

    def load_user_data(self):
        if os.path.exists('user_data.csv'):
            with open('user_data.csv', mode='r') as file:
                reader = csv.reader(file)
                self.user_data = {rows[0]: rows[1:] for rows in reader}

    def save_user_data(self):
        with open('user_data.csv', mode='w', newline='') as file:
            writer = csv.writer(file)
            for user, data in self.user_data.items():
                writer.writerow([user] + data)

    def create_login_screen(self):
        self.clear_screen()
        tk.Label(self.root, text="사용자 이름:").pack()
        self.username_entry = tk.Entry(self.root)
        self.username_entry.pack()

        tk.Label(self.root, text="비밀번호:").pack()
        self.password_entry = tk.Entry(self.root, show="*")
        self.password_entry.pack()

        self.login_button = tk.Button(self.root, text="로그인", command=self.login)
        self.login_button.pack()

        self.register_button = tk.Button(self.root, text="회원가입", command=self.register)
        self.register_button.pack()

    def clear_screen(self):
        for widget in self.root.winfo_children():
            widget.destroy()

    def register(self):
        username = self.username_entry.get()
        password = self.password_entry.get()

        if len(username) > 15:
            messagebox.showerror("오류", "사용자 이름은 15자 이하여야 합니다.")
            return

        if username in self.user_data:
            messagebox.showerror("오류", "이미 존재하는 사용자 이름입니다.")
            return

        self.user_data[username] = [password, '0', '0', str(INITIAL_CHIPS)]
        self.save_user_data()
        messagebox.showinfo("성공", "회원가입이 완료되었습니다!")
        self.login()

    def login(self):
        username = self.username_entry.get()
        password = self.password_entry.get()

        if username not in self.user_data or self.user_data[username][0] != password:
            messagebox.showerror("오류", "잘못된 사용자 이름 또는 비밀번호입니다.")
            return

        self.current_user = username
        self.balance = float(self.user_data[username][3])
        self.games_played = int(self.user_data[username][1])
        self.games_won = int(self.user_data[username][2])

        self.show_game_info()
        self.create_bet_screen()

    def show_game_info(self):
        if self.games_played == 0:
            win_rate = 0
        else:
            win_rate = self.games_won / self.games_played * 100

        messagebox.showinfo(
            "게임 정보",
            f"게임 횟수: {self.games_played}\n게임 승리 횟수: {self.games_won}\n승률: {win_rate:.2f}%"
        )

    def create_bet_screen(self):
        self.clear_screen()

        if self.balance < 1:
            self.balance = INITIAL_CHIPS
            messagebox.showinfo("알림", "칩이 500칩으로 재설정되었습니다.")

        tk.Label(self.root, text="블랙잭에 오신 것을 환영합니다!").pack()

        self.balance_label = tk.Label(self.root, text=f"칩: {self.balance}")
        self.balance_label.pack()

        self.bet_entry = tk.Entry(self.root)
        self.bet_entry.pack()
        self.bet_button = tk.Button(self.root, text="베팅", command=self.place_bet)
        self.bet_button.pack()

        self.hit_button = tk.Button(self.root, text="카드 받기", command=self.hit, state=tk.DISABLED)
        self.hit_button.pack()
        self.stand_button = tk.Button(self.root, text="멈추기", command=self.stand, state=tk.DISABLED)
        self.stand_button.pack()

        self.result_label = tk.Label(self.root, text="")
        self.result_label.pack()

        self.play_again_button = tk.Button(self.root, text="다시하기", command=self.play_again, state=tk.DISABLED)
        self.play_again_button.pack()

        self.show_rankings(show_once=True)

    def place_bet(self):
        try:
            self.bet = int(self.bet_entry.get())
        except ValueError:
            messagebox.showerror("오류", "잘못된 베팅 금액입니다.")
            return

        if self.bet > self.balance or self.bet <= 0:
            messagebox.showerror("오류", "잘못된 베팅 금액입니다.")
        else:
            self.start_game()

    def start_game(self):
        self.deck = self.create_deck()
        self.player_hand = [self.deck.pop(), self.deck.pop()]
        self.dealer_hand = [self.deck.pop(), self.deck.pop()]

        self.hit_button.config(state=tk.NORMAL)
        self.stand_button.config(state=tk.NORMAL)

        self.update_result(initial=True)

    def hit(self):
        self.player_hand.append(self.deck.pop())
        self.update_result()

    def stand(self):
        while self.calculate_hand_value(self.dealer_hand) < 17:
            self.dealer_hand.append(self.deck.pop())
            self.update_result()

        player_value = self.calculate_hand_value(self.player_hand)
        dealer_value = self.calculate_hand_value(self.dealer_hand)


        if player_value > 21:
            self.end_game(f"플레이어의 버스트! 욕심을 조금 버려야겠어요 하하!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=-self.bet)
        elif player_value == 21 and len(self.player_hand) == 2:
            self.end_game(f"블랙잭! 운이 좋네요! \n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=self.bet * 2)
        elif dealer_value > 21:
            self.end_game(f"딜러의 버스트! 운이 좋았네요!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=self.bet)
        elif player_value == dealer_value:
            self.end_game(f"무승부입니다!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=0)
        elif player_value > dealer_value:
            self.end_game(f"당신은 숫자의 우위를 점하였습니다!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=self.bet)
        else:
            self.end_game(f"당신은 숫자의 우위를 점하지 못하였습니다!\n 딜러의 손패: {self.dealer_hand}, (값: {dealer_value})\n 당신의 손패: {self.player_hand}, (값: {player_value})", chips_changed=-self.bet)

    def end_game(self, result, chips_changed):
        self.games_played += 1
        if "승리" in result.lower() or "블랙잭" in result:
            self.games_won += 1
        self.balance += chips_changed

        self.result_label.config(text=f"{result}\n칩 변화: {chips_changed}")
        self.balance_label.config(text=f"잔고: {self.balance}")
        self.hit_button.config(state=tk.DISABLED)
        self.stand_button.config(state=tk.DISABLED)
        self.play_again_button.config(state=tk.NORMAL)

        self.user_data[self.current_user][1] = str(self.games_played)
        self.user_data[self.current_user][2] = str(self.games_won)
        self.user_data[self.current_user][3] = str(self.balance)
        self.save_user_data()

    def play_again(self):
        self.bet_entry.delete(0, tk.END)
        self.result_label.config(text="")
        self.play_again_button.config(state=tk.DISABLED)

        self.hit_button.config(state=tk.DISABLED)
        self.stand_button.config(state=tk.DISABLED)

        if messagebox.askyesno("다시하기", "다시 한 판 하시겠습니까?"):
            self.create_bet_screen()
        else:
            self.create_login_screen()

    def show_rankings(self, show_once=False):
        rankings = sorted(self.user_data.items(), key=lambda x: int(float(x[1][3])), reverse=True)
        ranking_text = "랭킹:\n"
        for rank, (user, data) in enumerate(rankings, 1):
            ranking_text += f"{rank}. {user} - 칩: {data[3]}\n"
        
        messagebox.showinfo("랭킹", ranking_text)
        if show_once:
            self.show_rankings = lambda *args, **kwargs: None

if __name__ == "__main__":
    root = tk.Tk()
    game = BlackjackGame(root)
    root.mainloop()


