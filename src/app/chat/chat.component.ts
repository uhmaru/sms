import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { NgIf, NgFor, NgClass, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { environment } from '../../environments/environment';
import { AuthService } from '../services/auth.service';

interface Message {
  body: string;
  direction: 'incoming' | 'outgoing';
  created_at: string;
  status?: 'pending' | 'sent' | 'failed';
  user_id: string;
  phone_number: string;
}

@Component({
  standalone: true,
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss'],
  imports: [NgIf, NgFor, NgClass, DatePipe, FormsModule]
})
export class ChatComponent implements OnInit {
  messages: Message[] = [];
  newMessage = '';
  inputPhoneNumber: string = '';
  baseUrl = environment.apiBaseUrl;
  currentUserId: string = '';
  errorMessage: string | null = null;

  @ViewChild('messagesContainer') messagesContainer!: ElementRef;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.currentUserId = this.authService.getCurrentUserId() || '';
    this.loadMessages();
  }

  logout() {
    this.authService.logout();
  }

  loadMessages() {
    this.http.get<{ messages: Message[] }>(`${this.baseUrl}/messages`).subscribe({
      next: (data) => {
        this.messages = data.messages;
        setTimeout(() => this.scrollToBottom(), 0);
      },
      error: (err) => {
        console.error('Failed to load messages', err);
        this.errorMessage = 'Failed to load messages.';
      }
    });
  }

  sendMessage() {
    if (!this.newMessage.trim()) return;

    const trimmedBody = this.newMessage.trim();
    if (trimmedBody.length > 250) {
      this.errorMessage = 'Message cannot exceed 250 characters.';
      return;
    }

    const rawPhoneNumber = this.inputPhoneNumber.replace(/\D/g, '');

    if (rawPhoneNumber.length !== 10) {
      this.errorMessage = 'Phone number must be 10 digits.';
      return;
    }

    const deliveryToken = this.generateSecureToken();

    const tempMessage: Message = {
      body: trimmedBody,
      direction: 'outgoing',
      created_at: new Date().toISOString(),
      status: 'pending',
      user_id: this.currentUserId,
      phone_number: rawPhoneNumber
    };

    this.messages.push(tempMessage);
    const index = this.messages.length - 1;
    this.scrollToBottom();

    this.newMessage = '';
    this.errorMessage = null;

    this.http
      .post<{ message: Message }>(`${this.baseUrl}/messages`, {
        message: {
          body: trimmedBody,
          phone_number: rawPhoneNumber,
          delivery_token: deliveryToken
        }
      })
      .subscribe({
        next: (res) => {
          this.messages[index] = {
            ...res.message,
            direction: 'outgoing',
            status: 'sent'
          };
          this.scrollToBottom();
        },
        error: (err) => {
          this.messages[index].status = 'failed';
          const backendMessage =
            err?.error?.errors?.[0] ||
            err?.error?.error ||
            'Failed to send message.';
          this.errorMessage = backendMessage;
          console.error('Failed to send message:', err);
        }
      });
  }

  clearMessage() {
    this.newMessage = '';
  }

  scrollToBottom() {
    try {
      this.messagesContainer.nativeElement.scrollTop =
        this.messagesContainer.nativeElement.scrollHeight;
    } catch (err) {
      console.error('Scroll error', err);
    }
  }

  formatDisplayPhoneNumber(phone: string): string {
    const digits = phone.replace(/\D/g, '');

    if (digits.length !== 10) return phone;

    return `${digits.slice(0, 3)}-${digits.slice(3, 6)}-${digits.slice(6)}`;
  }

  onPhoneInput(value: string) {
    this.inputPhoneNumber = this.formatPhoneNumber(value);
  }

  private formatPhoneNumber(value: string): string {
    const digits = value.replace(/\D/g, '');

    if (digits.length === 0) return '';

    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return `${digits.slice(0, 3)}-${digits.slice(3)}`;
    } else {
      return `${digits.slice(0, 3)}-${digits.slice(3, 6)}-${digits.slice(6, 10)}`;
    }
  }


  private generateSecureToken(): string {
    return crypto.getRandomValues(new Uint8Array(16)).reduce((acc, byte) => {
      return acc + byte.toString(16).padStart(2, '0');
    }, '');
  }
}

