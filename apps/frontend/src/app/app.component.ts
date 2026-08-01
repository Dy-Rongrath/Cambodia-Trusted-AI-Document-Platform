import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'Cambodia Trusted AI Document Platform';
  subtitle = 'Phase 1 — Engineering Scaffold';
  environment = 'Pre-release development environment';
}
