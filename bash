<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login()
    {
        return view('auth.login');
    }

    public function doLogin(Request $request)
    {
        $credentials = $request->only('username', 'password');

        if (Auth::attempt($credentials)) {
            return redirect('/dashboard');
        }

        return back()->withErrors(['بيانات الدخول غير صحيحة']);
    }

    public function logout()
    {
        Auth::logout();
        return redirect('/login');
    }
}
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle($request, Closure $next)
    {
        if (Auth::user()->role !== 'admin') {
            abort(403);
        }

        return $next($request);
    }
}
'admin' => \App\Http\Middleware\AdminMiddleware::class,
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        $users = User::all();
        return view('users.index', compact('users'));
    }

    public function create()
    {
        return view('users.create');
    }

    public function store(Request $request)
    {
        User::create([
            'name' => $request->name,
            'username' => $request->username,
            'role' => $request->role,
            'password' => Hash::make($request->password),
        ]);

        return redirect('/users');
    }
}
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;

Route::get('/login', [AuthController::class, 'login']);
Route::post('/login', [AuthController::class, 'doLogin']);
Route::get('/logout', [AuthController::class, 'logout']);

Route::middleware('auth')->group(function () {

    Route::get('/dashboard', function () {
        return view('dashboard');
    });

    Route::middleware('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::get('/users/create', [UserController::class, 'create']);
        Route::post('/users', [UserController::class, 'store']);
    });

});
<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>متجر هواتف الحيدرة</title>
</head>
<body>

<h3>متجر هواتف الحيدرة</h3>

<form method="POST">
    @csrf
    <input name="username" placeholder="اسم المستخدم"><br><br>
    <input type="password" name="password" placeholder="كلمة المرور"><br><br>
    <button>تسجيل الدخول</button>
</form>

</body>
</html>
<h3>لوحة التحكم – متجر هواتف الحيدرة</h3>

@if(auth()->user()->role === 'admin')
    <a href="/users">إدارة المستخدمين</a>
@endif

<br><br>
<a href="/logout">تسجيل خروج</a>
<h3>إدارة المستخدمين</h3>

<a href="/users/create">➕ إضافة مستخدم</a>

<table border="1" cellpadding="5">
    <tr>
        <th>الاسم</th>
        <th>اسم المستخدم</th>
        <th>الدور</th>
    </tr>

    @foreach($users as $user)
    <tr>
        <td>{{ $user->name }}</td>
        <td>{{ $user->username }}</td>
        <td>{{ $user->role }}</td>
    </tr>
    @endforeach
</table>
<h3>إضافة مستخدم جديد</h3>

<form method="POST" action="/users">
    @csrf

    <input name="name" placeholder="الاسم"><br><br>
    <input name="username" placeholder="اسم المستخدم"><br><br>
    <input type="password" name="password" placeholder="كلمة المرور"><br><br>

    <select name="role">
        <option value="admin">أدمن</option>
        <option value="cashier">كاشير</option>
    </select><br><br>

    <button>حفظ</button>
</form>
public function up()
{
    Schema::create('users', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->string('username')->unique();
        $table->enum('role', ['admin', 'cashier']);
        $table->boolean('status')->default(1);
        $table->string('password');
        $table->timestamps();
    });
}
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        User::create([
            'name' => 'Admin',
            'username' => 'admin',
            'role' => 'admin',
            'password' => Hash::make('123456'),
        ]);
    }
}
php artisan migrate:fresh
php artisan db:seed --class=AdminSeeder
php artisan serve
