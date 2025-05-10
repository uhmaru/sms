import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap, catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';
import { environment } from '../../environments/environment';
import { jwtDecode } from 'jwt-decode';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private tokenKey = 'auth_token';
  private userIdKey = 'currentUserId';
  private baseUrl = environment.apiBaseUrl;

  constructor(private http: HttpClient, private router: Router) {}

  login(credentials: { email: string; password: string }) {
    return this.http.post<{ token: string }>(
      `${this.baseUrl}/login`,
      { user: credentials }
    ).pipe(
      tap(response => {
        this.setToken(response.token);
        this.router.navigate(['/messages']);
      }),
      catchError(error => {
        console.error('Login failed', error);
        return throwError(() => error);
      })
    );
  }

  register(data: { email: string; password: string, password_confirmation: string }) {
    return this.http.post<{ token: string }>(
      `${this.baseUrl}/`,
      { user: data }
    ).pipe(
      tap(response => {
        this.setToken(response.token);
        this.router.navigate(['/messages']);
      }),
      catchError(error => {
        console.error('Registration failed', error);
        return throwError(() => error);
      })
    );
  }

  logout() {
    const token = this.getToken();
    if (!token) {
      this.performClientLogout();
      return;
    }

    this.http.delete(`${this.baseUrl}/logout`, {
      headers: { Authorization: `Bearer ${token}` }
    }).subscribe({
      next: () => this.performClientLogout(),
      error: (err) => {
        console.warn('Logout request failed, proceeding anyway:', err);
        this.performClientLogout();
      }
    });
  }


  isAuthenticated(): boolean {
    const token = this.getToken();
    return !!token && !this.isTokenExpired(token);
  }

  getToken(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('auth_token');
  }

  getCurrentUserId(): string | null {
    return localStorage.getItem(this.userIdKey);
  }

  private setToken(token: string) {
    localStorage.setItem(this.tokenKey, token);

    try {
      const decoded: any = jwtDecode(token);
      const userId = decoded.sub || decoded.user_id || decoded.id;
      if (userId) {
        localStorage.setItem(this.userIdKey, userId);
      }
    } catch (err) {
      console.error('Failed to decode token', err);
    }
  }

  private performClientLogout() {
    this.clearToken();
    this.router.navigate(['/']);
  }

  private clearToken() {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userIdKey);
  }

  private isTokenExpired(token: string): boolean {
    try {
      const decoded: any = jwtDecode(token);
      return decoded.exp && (Date.now() / 1000 > decoded.exp);
    } catch {
      return true;
    }
  }
}
