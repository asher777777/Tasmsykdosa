import { Application } from '@nativescript/core';
import { WebViewExt } from '@nativescript/web-view-ext';

Application.run({
  create: () => {
    const webView = new WebViewExt();
    webView.src = 'https://your-deployed-url.com'; // החלף עם כתובת האתר המלאה שלך
    return webView;
  }
});