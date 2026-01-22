# Add this to users/views.py after the recommend_video_to_user function

@csrf_exempt
def get_trainer_details(request, trainer_id):
    """
    Get trainer details by ID
    """
    if request.method == 'GET':
        try:
            trainer = Trainer.objects.get(id=trainer_id)
            
            return JsonResponse({
                'success': True,
                'id': trainer.id,
                'name': trainer.user.name,
                'email': trainer.user.emailid,
                'mobile': trainer.mobile,
                'gender': trainer.gender,
                'experience': trainer.experience,
                'specialization': trainer.specialization,
                'certification': trainer.certification,
                'goal_category': trainer.goal_category,
                'joining_period': trainer.joining_period,
                'is_active': trainer.is_active
            }, status=200)
            
        except Trainer.DoesNotExist:
            return JsonResponse({
                'success': False,
                'message': 'Trainer not found'
            }, status=404)
        except Exception as e:
            return JsonResponse({
                'success': False,
                'message': str(e)
            }, status=500)
    
    return JsonResponse({
        'success': False,
        'message': 'Only GET method is allowed'
    }, status=405)


# Add this to gym_backend/urls.py:
# path('api/trainers/<int:trainer_id>/', get_trainer_details, name='get_trainer_details'),
