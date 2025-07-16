// Application JavaScript for Ads Microsite
class AdsMicrosite {
    constructor() {
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupScrollEffects();
        this.setupFormValidation();
        this.setupAnimations();
    }

    setupEventListeners() {
        // Navigation smooth scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    const headerOffset = 80;
                    const elementPosition = target.getBoundingClientRect().top;
                    const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                    window.scrollTo({
                        top: offsetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });

        // CTA buttons
        const notifyBtn = document.getElementById('notify-btn');
        const learnMoreBtn = document.getElementById('learn-more-btn');

        if (notifyBtn) {
            notifyBtn.addEventListener('click', () => {
                this.scrollToSection('#contact');
            });
        }

        if (learnMoreBtn) {
            learnMoreBtn.addEventListener('click', () => {
                this.scrollToSection('#features');
            });
        }

        // Form submission
        const contactForm = document.getElementById('contact-form');
        if (contactForm) {
            contactForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleFormSubmission(e);
            });
        }

        // Modal close
        const modalClose = document.getElementById('modal-close');
        if (modalClose) {
            modalClose.addEventListener('click', () => {
                this.closeModal();
            });
        }

        // Close modal on backdrop click
        const modal = document.getElementById('success-modal');
        if (modal) {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal();
                }
            });
        }

        // Escape key to close modal
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeModal();
            }
        });
    }

    setupScrollEffects() {
        // Header background on scroll
        const header = document.querySelector('.header');
        let lastScrollY = window.scrollY;

        window.addEventListener('scroll', () => {
            const currentScrollY = window.scrollY;
            
            if (header) {
                if (currentScrollY > 50) {
                    header.style.background = 'rgba(255, 255, 255, 0.98)';
                    header.style.boxShadow = '0 4px 6px -1px rgb(0 0 0 / 0.1)';
                } else {
                    header.style.background = 'rgba(255, 255, 255, 0.95)';
                    header.style.boxShadow = 'none';
                }

                // Hide/show header on scroll
                if (currentScrollY > lastScrollY && currentScrollY > 100) {
                    header.style.transform = 'translateY(-100%)';
                } else {
                    header.style.transform = 'translateY(0)';
                }
            }

            lastScrollY = currentScrollY;
        });

        // Intersection Observer for animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-in');
                }
            });
        }, observerOptions);

        // Observe elements for animation
        document.querySelectorAll('.feature-card, .floating-card, .about-visual').forEach(el => {
            observer.observe(el);
        });
    }

    setupFormValidation() {
        const form = document.getElementById('contact-form');
        if (!form) return;

        const inputs = form.querySelectorAll('input, select');
        
        inputs.forEach(input => {
            input.addEventListener('blur', () => {
                this.validateField(input);
            });

            input.addEventListener('input', () => {
                this.clearFieldError(input);
            });
        });
    }

    validateField(field) {
        const value = field.value.trim();
        let isValid = true;
        let errorMessage = '';

        // Remove existing error
        this.clearFieldError(field);

        switch (field.type) {
            case 'email':
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!value) {
                    isValid = false;
                    errorMessage = 'Email is required';
                } else if (!emailRegex.test(value)) {
                    isValid = false;
                    errorMessage = 'Please enter a valid email address';
                }
                break;
            case 'text':
                if (field.hasAttribute('required') && !value) {
                    isValid = false;
                    errorMessage = 'This field is required';
                }
                break;
            case 'select-one':
                if (field.hasAttribute('required') && !value) {
                    isValid = false;
                    errorMessage = 'Please select an option';
                }
                break;
        }

        if (!isValid) {
            this.showFieldError(field, errorMessage);
        }

        return isValid;
    }

    showFieldError(field, message) {
        field.classList.add('error');
        
        let errorElement = field.parentNode.querySelector('.field-error');
        if (!errorElement) {
            errorElement = document.createElement('div');
            errorElement.className = 'field-error';
            field.parentNode.appendChild(errorElement);
        }
        
        errorElement.textContent = message;
        errorElement.style.display = 'block';
        errorElement.style.color = '#ef4444';
        errorElement.style.fontSize = '0.875rem';
        errorElement.style.marginTop = '0.25rem';
    }

    clearFieldError(field) {
        field.classList.remove('error');
        const errorElement = field.parentNode.querySelector('.field-error');
        if (errorElement) {
            errorElement.style.display = 'none';
        }
    }

    async handleFormSubmission(event) {
        const form = event.target;
        const submitBtn = document.getElementById('submit-btn');
        const btnText = submitBtn.querySelector('.btn-text');
        const btnLoading = submitBtn.querySelector('.btn-loading');

        // Validate all fields
        const inputs = form.querySelectorAll('input[required], select[required]');
        let isFormValid = true;

        inputs.forEach(input => {
            if (!this.validateField(input)) {
                isFormValid = false;
            }
        });

        if (!isFormValid) {
            this.showFormError('Please fix the errors above');
            return;
        }

        // Show loading state
        submitBtn.disabled = true;
        btnText.style.display = 'none';
        btnLoading.style.display = 'flex';

        try {
            // Simulate API call
            await this.submitToAPI(new FormData(form));
            
            // Show success
            this.showSuccessModal();
            form.reset();
            
        } catch (error) {
            console.error('Form submission error:', error);
            this.showFormError('Something went wrong. Please try again.');
        } finally {
            // Reset button state
            submitBtn.disabled = false;
            btnText.style.display = 'block';
            btnLoading.style.display = 'none';
        }
    }

    async submitToAPI(formData) {
        // Simulate API call - replace with actual endpoint
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                // Simulate success/failure
                const success = Math.random() > 0.1; // 90% success rate
                
                if (success) {
                    console.log('Form data:', Object.fromEntries(formData));
                    resolve({ success: true });
                } else {
                    reject(new Error('API Error'));
                }
            }, 2000);
        });
    }

    showFormError(message) {
        const form = document.getElementById('contact-form');
        let errorElement = form.querySelector('.form-error');
        
        if (!errorElement) {
            errorElement = document.createElement('div');
            errorElement.className = 'form-error';
            errorElement.style.cssText = `
                background: #fee2e2;
                color: #dc2626;
                padding: 1rem;
                border-radius: 0.5rem;
                margin-top: 1rem;
                font-size: 0.875rem;
                border: 1px solid #fecaca;
            `;
            form.appendChild(errorElement);
        }
        
        errorElement.textContent = message;
        errorElement.style.display = 'block';
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            if (errorElement) {
                errorElement.style.display = 'none';
            }
        }, 5000);
    }

    showSuccessModal() {
        const modal = document.getElementById('success-modal');
        if (modal) {
            modal.classList.add('show');
            document.body.style.overflow = 'hidden';
        }
    }

    closeModal() {
        const modal = document.getElementById('success-modal');
        if (modal) {
            modal.classList.remove('show');
            document.body.style.overflow = '';
        }
    }

    scrollToSection(selector) {
        const target = document.querySelector(selector);
        if (target) {
            const headerOffset = 80;
            const elementPosition = target.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    }

    setupAnimations() {
        // Add CSS for animated elements
        const style = document.createElement('style');
        style.textContent = `
            .feature-card,
            .floating-card,
            .about-visual {
                opacity: 0;
                transform: translateY(30px);
                transition: opacity 0.6s ease-out, transform 0.6s ease-out;
            }
            
            .feature-card.animate-in,
            .floating-card.animate-in,
            .about-visual.animate-in {
                opacity: 1;
                transform: translateY(0);
            }
            
            .floating-card.animate-in {
                animation: float 6s ease-in-out infinite;
            }
            
            .field-error {
                opacity: 0;
                transform: translateY(-10px);
                transition: opacity 0.3s ease-out, transform 0.3s ease-out;
            }
            
            .field-error[style*="block"] {
                opacity: 1;
                transform: translateY(0);
            }
            
            input.error,
            select.error {
                border-color: #ef4444 !important;
                box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1) !important;
            }
        `;
        document.head.appendChild(style);
    }

    // Utility methods
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    throttle(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }
}

// Analytics and tracking (placeholder)
class Analytics {
    static track(event, properties = {}) {
        // Placeholder for analytics tracking
        console.log('Analytics event:', event, properties);
        
        // Example: Google Analytics 4
        if (typeof gtag !== 'undefined') {
            gtag('event', event, properties);
        }
        
        // Example: Custom analytics
        if (typeof customAnalytics !== 'undefined') {
            customAnalytics.track(event, properties);
        }
    }

    static pageView(page) {
        this.track('page_view', { page });
    }

    static buttonClick(buttonName) {
        this.track('button_click', { button_name: buttonName });
    }

    static formSubmit(formName) {
        this.track('form_submit', { form_name: formName });
    }
}

// Performance monitoring
class Performance {
    static measurePageLoad() {
        window.addEventListener('load', () => {
            const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
            Analytics.track('page_load_time', { load_time: loadTime });
        });
    }

    static measureInteraction(name, fn) {
        const start = performance.now();
        const result = fn();
        const end = performance.now();
        
        Analytics.track('interaction_time', {
            interaction: name,
            duration: end - start
        });
        
        return result;
    }
}

// Error handling
class ErrorHandler {
    static init() {
        window.addEventListener('error', (event) => {
            console.error('JavaScript error:', event.error);
            Analytics.track('javascript_error', {
                message: event.message,
                filename: event.filename,
                line: event.lineno,
                column: event.colno
            });
        });

        window.addEventListener('unhandledrejection', (event) => {
            console.error('Unhandled promise rejection:', event.reason);
            Analytics.track('promise_rejection', {
                reason: event.reason?.message || 'Unknown'
            });
        });
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    // Initialize main app
    const app = new AdsMicrosite();
    
    // Initialize performance monitoring
    Performance.measurePageLoad();
    
    // Initialize error handling
    ErrorHandler.init();
    
    // Track page view
    Analytics.pageView(window.location.pathname);
    
    // Add click tracking to CTA buttons
    document.querySelectorAll('.btn').forEach(btn => {
        btn.addEventListener('click', () => {
            Analytics.buttonClick(btn.textContent.trim());
        });
    });
    
    console.log('🚀 Ads Microsite initialized successfully');
});

// Export for testing or external use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { AdsMicrosite, Analytics, Performance, ErrorHandler };
}
