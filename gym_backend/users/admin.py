from django.contrib import admin
from django import forms
from django.utils.safestring import mark_safe
from .models import UserLogin, Trainer, WorkoutVideo, ChatMessage, FoodRecipe, FoodItem, FoodEntry, OTP, PaymentTransaction

# Register your models here.

@admin.register(UserLogin)
class UserLoginAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'emailid', 'role', 'is_active', 'created_at')
    list_filter = ('role', 'is_active', 'created_at')
    search_fields = ('name', 'emailid')
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('-created_at',)
    
    fieldsets = (
        ('User Information', {
            'fields': ('name', 'emailid', 'password', 'role')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

@admin.register(Trainer)
class TrainerAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_trainer_name', 'get_trainer_email', 'mobile', 'gender', 'experience', 'specialization', 'joining_period', 'created_at')
    list_filter = ('gender', 'specialization', 'joining_period', 'created_at')
    search_fields = ('user__name', 'user__emailid', 'mobile')
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)
    
    def get_trainer_name(self, obj):
        return obj.user.name
    get_trainer_name.short_description = 'Name'
    
    def get_trainer_email(self, obj):
        return obj.user.emailid
    get_trainer_email.short_description = 'Email'
    
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Trainer Details', {
            'fields': ('mobile', 'gender', 'experience', 'specialization', 'joining_period')
        }),
        ('Timestamps', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )

@admin.register(WorkoutVideo)
class WorkoutVideoAdmin(admin.ModelAdmin):
    list_display = ('day_number', 'title', 'goal_type', 'difficulty_level', 'uploaded_via', 'uploaded_by', 'is_active', 'created_at')
    list_filter = ('uploaded_via', 'goal_type', 'difficulty_level', 'is_active', 'created_at')
    search_fields = ('title', 'description')
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('day_number', 'goal_type', 'difficulty_level')
    
    fieldsets = (
        ('Video Information', {
            'fields': ('title', 'description', 'video_file', 'thumbnail', 'duration')
        }),
        ('Classification', {
            'fields': ('goal_type', 'difficulty_level', 'min_weight_difference', 'max_weight_difference')
        }),
        ('Upload Details', {
            'fields': ('uploaded_by', 'uploaded_via', 'day_number')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        """
        Filter trainers based on their goal_category
        """
        if db_field.name == 'uploaded_by':
            # Get goal_type from POST (form submission) or from the object being edited
            goal_type = None
            
            # Try to get from POST data
            if request.method == 'POST':
                goal_type = request.POST.get('goal_type')
            
            # Filter trainers by goal_category
            if goal_type:
                kwargs['queryset'] = Trainer.objects.filter(
                    goal_category=goal_type
                ).select_related('user').order_by('user__name')
            else:
                kwargs['queryset'] = Trainer.objects.select_related('user').order_by('user__name')
        
        return super().formfield_for_foreignkey(db_field, request, **kwargs)
    
    class Media:
        js = ('admin/js/video_trainer_filter.js',)
    
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        return qs.select_related('uploaded_by', 'uploaded_by__user')

@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_user_name', 'get_trainer_name', 'sender_type', 'is_read', 'created_at')
    list_filter = ('sender_type', 'is_read', 'created_at')
    search_fields = ('user__user__name', 'trainer__user__name', 'message')
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)
    
    def get_user_name(self, obj):
        return obj.user.user.name
    get_user_name.short_description = 'User'
    
    def get_trainer_name(self, obj):
        return obj.trainer.user.name
    get_trainer_name.short_description = 'Trainer'
    
    fieldsets = (
        ('Chat Participants', {
            'fields': ('user', 'trainer')
        }),
        ('Message Details', {
            'fields': ('message', 'sender_type', 'is_read')
        }),
        ('Timestamp', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )

@admin.register(FoodRecipe)
class FoodRecipeAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'food_type', 'created_by', 'created_at')
    list_filter = ('food_type', 'created_at')
    search_fields = ('name', 'ingredients', 'instructions')
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)
    
    fieldsets = (
        ('Recipe Information', {
            'fields': ('name', 'food_type', 'created_by')
        }),
        ('Recipe Details', {
            'fields': ('ingredients', 'instructions')
        }),
        ('Timestamp', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )

@admin.register(FoodItem)
class FoodItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'food_category', 'diet_type', 'calories', 'protein', 'carbs', 'fats', 'serving_size', 'created_at')
    list_filter = ('food_category', 'diet_type', 'created_at')
    search_fields = ('name',)
    readonly_fields = ('created_at',)
    ordering = ('name',)
    
    fieldsets = (
        ('Food Information', {
            'fields': ('name', 'food_category', 'diet_type', 'serving_size')
        }),
        ('Nutritional Values (per 100g)', {
            'fields': ('calories', 'protein', 'carbs', 'fats')
        }),
        ('Timestamp', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        }),
    )

@admin.register(FoodEntry)
class FoodEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_user_name', 'get_food_name', 'quantity', 'quantity_unit', 'meal_type', 'calculated_calories', 'entry_date', 'created_at')
    list_filter = ('meal_type', 'entry_date', 'created_at')
    search_fields = ('user__name', 'food_item__name')
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('-entry_date', '-created_at')
    
    def get_user_name(self, obj):
        return obj.user.name
    get_user_name.short_description = 'User'
    
    def get_food_name(self, obj):
        return obj.food_item.name
    get_food_name.short_description = 'Food Item'
    
    fieldsets = (
        ('User & Food', {
            'fields': ('user', 'food_item')
        }),
        ('Quantity & Meal', {
            'fields': ('quantity', 'quantity_unit', 'meal_type', 'entry_date')
        }),
        ('Calories', {
            'fields': ('calculated_calories', 'is_custom_calories')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'otp_code', 'is_verified', 'attempt_count', 'created_at', 'expires_at')
    list_filter = ('is_verified', 'created_at', 'expires_at')
    search_fields = ('email',)
    readonly_fields = ('created_at', 'otp_code', 'expires_at')
    ordering = ('-created_at',)


@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'receipt_number', 'get_user_name', 'amount', 'payment_method', 'renewal_period', 'status', 'transaction_date')
    list_filter = ('payment_method', 'status', 'renewal_period', 'transaction_date')
    search_fields = ('user__name', 'user__emailid', 'receipt_number')
    readonly_fields = ('transaction_date', 'receipt_number')
    ordering = ('-transaction_date',)
    
    def get_user_name(self, obj):
        return obj.user.name
    get_user_name.short_description = 'User Name'
    
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Payment Details', {
            'fields': ('amount', 'payment_method', 'renewal_period', 'discount_percentage')
        }),
        ('Transaction Info', {
            'fields': ('receipt_number', 'status', 'transaction_date')
        }),
    )


