<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        {{-- Fonts --}}
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        {{-- Favicon (optional, remove if not needed) --}}
        <link rel="icon" type="image/png" href="{{ asset('favicon.png') }}">

        {{-- Scripts & Styles from Vite --}}
        @if (app()->environment('local'))
            {{-- Use dev server during local development --}}
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        @else
            {{-- Force load from public/build in production --}}
            @php
                $manifestPath = public_path('build/manifest.json');
                if (!file_exists($manifestPath)) {
                    echo "<!-- Manifest not found: run npm run build -->";
                }
            @endphp
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        @endif

        {{-- Optional: PWA/Meta --}}
        <meta name="theme-color" content="#1f2937">
    </head>

    <body class="font-sans antialiased h-full bg-gray-100 dark:bg-gray-900">
        <div class="min-h-screen flex flex-col">
            {{-- Top Navigation --}}
            @includeWhen(View::exists('layouts.navigation'), 'layouts.navigation')

            {{-- Page Header --}}
            @isset($header)
                <header class="bg-white dark:bg-gray-800 shadow">
                    <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
                        {{ $header }}
                    </div>
                </header>
            @endisset

            {{-- Page Body --}}
            <main class="flex-1">
                {{ $slot }}
            </main>
        </div>

        {{-- Optional: JS hook for modal or Livewire --}}
        @stack('scripts')
    </body>
</html>
