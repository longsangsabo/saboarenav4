import os
import json
from supabase import create_client, Client

def audit_qr_referral_system():
    """
    Comprehensive audit of QR code and referral system
    Check for issues, inconsistencies, and potential problems
    """
    
    print("🔍 SABO Arena QR Code & Referral System Audit")
    print("=" * 60)
    
    # Load environment variables
    try:
        with open('env.json', 'r') as f:
            env_vars = json.load(f)
        
        url = env_vars.get('SUPABASE_URL')
        service_key = env_vars.get('SUPABASE_SERVICE_ROLE_KEY')
        
        if not url or not service_key:
            print("❌ Missing Supabase credentials in env.json")
            return False
        
        supabase: Client = create_client(url, service_key)
        print("✅ Supabase connection established")
        
    except Exception as e:
        print(f"❌ Environment setup error: {str(e)}")
        return False
    
    audit_results = {
        'database': {},
        'services': {},
        'ui_components': {},
        'integration': {},
        'issues': [],
        'recommendations': []
    }
    
    print("\n" + "="*60)
    print("📊 1. DATABASE AUDIT")
    print("="*60)
    
    try:
        # 1.1 Check referral_codes table
        print("\n🔍 Auditing referral_codes table...")
        codes_response = supabase.table('referral_codes').select('*').execute()
        
        if codes_response.data:
            codes_count = len(codes_response.data)
            print(f"✅ Found {codes_count} referral codes")
            
            # Analyze code patterns
            code_patterns = {}
            active_codes = 0
            expired_codes = 0
            future_codes = 0
            
            for code in codes_response.data:
                code_text = code.get('code', '')
                is_active = code.get('is_active', False)
                expires_at = code.get('expires_at')
                created_at = code.get('created_at')
                
                # Pattern analysis
                if code_text.startswith('SABO-'):
                    pattern = 'SABO-FORMAT'
                else:
                    pattern = 'OTHER'
                
                if pattern not in code_patterns:
                    code_patterns[pattern] = 0
                code_patterns[pattern] += 1
                
                # Status analysis
                if is_active:
                    active_codes += 1
                else:
                    expired_codes += 1
                
                print(f"   • {code_text} - Active: {is_active}, Created: {created_at[:10] if created_at else 'N/A'}")
            
            audit_results['database']['referral_codes'] = {
                'total': codes_count,
                'active': active_codes,
                'expired': expired_codes,
                'patterns': code_patterns
            }
            
            print(f"\n📊 Code Analysis:")
            print(f"   • Total codes: {codes_count}")
            print(f"   • Active codes: {active_codes}")
            print(f"   • Expired codes: {expired_codes}")
            print(f"   • Code patterns: {code_patterns}")
            
            # Check for potential issues
            if active_codes == 0:
                audit_results['issues'].append("⚠️ No active referral codes found")
            
            if 'OTHER' in code_patterns:
                audit_results['issues'].append(f"⚠️ {code_patterns['OTHER']} codes don't follow SABO- format")
        
        else:
            print("⚠️ No referral codes found in database")
            audit_results['issues'].append("⚠️ Empty referral_codes table")
        
        # 1.2 Check referral_usage table
        print(f"\n🔍 Auditing referral_usage table...")
        usage_response = supabase.table('referral_usage').select('*').execute()
        
        if usage_response.data:
            usage_count = len(usage_response.data)
            print(f"✅ Found {usage_count} usage records")
            
            total_spa_referrer = 0
            total_spa_referred = 0
            
            for usage in usage_response.data:
                spa_referrer = usage.get('spa_awarded_referrer', 0) or 0
                spa_referred = usage.get('spa_awarded_referred', 0) or 0
                used_at = usage.get('used_at', '')
                
                total_spa_referrer += spa_referrer
                total_spa_referred += spa_referred
                
                print(f"   • Used: {used_at[:10] if used_at else 'N/A'}, SPA: {spa_referrer}/{spa_referred}")
            
            audit_results['database']['referral_usage'] = {
                'total_usage': usage_count,
                'total_spa_referrer': total_spa_referrer,
                'total_spa_referred': total_spa_referred
            }
            
            print(f"\n📊 Usage Analysis:")
            print(f"   • Total usage: {usage_count}")
            print(f"   • Total SPA awarded to referrers: {total_spa_referrer}")
            print(f"   • Total SPA awarded to referred users: {total_spa_referred}")
            
        else:
            print("✅ No usage records (expected for new system)")
            audit_results['database']['referral_usage'] = {
                'total_usage': 0,
                'total_spa_referrer': 0,
                'total_spa_referred': 0
            }
        
        # 1.3 Check for orphaned records
        print(f"\n🔍 Checking for data integrity issues...")
        
        if codes_response.data and usage_response.data:
            code_ids = {code['id'] for code in codes_response.data}
            usage_code_ids = {usage['referral_code_id'] for usage in usage_response.data}
            
            orphaned_usage = usage_code_ids - code_ids
            if orphaned_usage:
                audit_results['issues'].append(f"⚠️ Found {len(orphaned_usage)} orphaned usage records")
                print(f"⚠️ Found {len(orphaned_usage)} orphaned usage records")
            else:
                print("✅ No orphaned usage records found")
        
    except Exception as e:
        print(f"❌ Database audit error: {str(e)}")
        audit_results['issues'].append(f"❌ Database audit failed: {str(e)}")
    
    print("\n" + "="*60)
    print("🛠️ 2. SERVICE FILES AUDIT")
    print("="*60)
    
    # 2.1 Check BasicReferralService
    print(f"\n🔍 Auditing BasicReferralService...")
    basic_service_path = 'lib/services/basic_referral_service.dart'
    
    if os.path.exists(basic_service_path):
        print(f"✅ BasicReferralService exists: {basic_service_path}")
        
        with open(basic_service_path, 'r', encoding='utf-8') as f:
            service_content = f.read()
        
        # Check for required methods
        required_methods = [
            'generateReferralCode',
            'applyReferralCode', 
            'getUserReferralStats',
            'isReferralCode',
            'getReferralCodeInfo'
        ]
        
        missing_methods = []
        for method in required_methods:
            if method not in service_content:
                missing_methods.append(method)
        
        if missing_methods:
            audit_results['issues'].append(f"⚠️ BasicReferralService missing methods: {missing_methods}")
            print(f"⚠️ Missing methods: {missing_methods}")
        else:
            print(f"✅ All required methods present: {required_methods}")
        
        audit_results['services']['basic_referral_service'] = {
            'exists': True,
            'methods': len(required_methods) - len(missing_methods),
            'missing_methods': missing_methods
        }
        
    else:
        print(f"❌ BasicReferralService not found: {basic_service_path}")
        audit_results['issues'].append("❌ BasicReferralService file missing")
        audit_results['services']['basic_referral_service'] = {'exists': False}
    
    # 2.2 Check QR Scan Service
    print(f"\n🔍 Auditing QRScanService...")
    qr_service_path = 'lib/services/qr_scan_service.dart'
    
    if os.path.exists(qr_service_path):
        print(f"✅ QRScanService exists: {qr_service_path}")
        
        with open(qr_service_path, 'r', encoding='utf-8') as f:
            qr_content = f.read()
        
        # Check if it uses BasicReferralService (not old ReferralService)
        if 'basic_referral_service.dart' in qr_content:
            print(f"✅ QRScanService uses BasicReferralService")
        elif 'referral_service.dart' in qr_content:
            audit_results['issues'].append("⚠️ QRScanService still references old ReferralService")
            print(f"⚠️ QRScanService references old ReferralService")
        else:
            audit_results['issues'].append("⚠️ QRScanService referral integration unclear")
            print(f"⚠️ Referral integration unclear in QRScanService")
        
        # Check for QR referral detection
        if 'isReferralCode' in qr_content:
            print(f"✅ QR referral code detection implemented")
        else:
            audit_results['issues'].append("⚠️ QR referral code detection missing")
            print(f"⚠️ QR referral code detection missing")
        
        audit_results['services']['qr_scan_service'] = {
            'exists': True,
            'uses_basic_service': 'basic_referral_service.dart' in qr_content,
            'has_referral_detection': 'isReferralCode' in qr_content
        }
        
    else:
        print(f"❌ QRScanService not found: {qr_service_path}")
        audit_results['issues'].append("❌ QRScanService file missing")
        audit_results['services']['qr_scan_service'] = {'exists': False}
    
    print("\n" + "="*60)
    print("🎨 3. UI COMPONENTS AUDIT")
    print("="*60)
    
    # 3.1 Check UI components
    ui_components = [
        'lib/presentation/widgets/basic_referral_card.dart',
        'lib/presentation/widgets/basic_referral_code_input.dart',
        'lib/presentation/widgets/basic_referral_stats_widget.dart',
        'lib/presentation/widgets/basic_referral_dashboard.dart'
    ]
    
    print(f"\n🔍 Auditing UI components...")
    
    for component_path in ui_components:
        component_name = os.path.basename(component_path).replace('.dart', '')
        
        if os.path.exists(component_path):
            print(f"✅ {component_name}")
            
            with open(component_path, 'r', encoding='utf-8') as f:
                component_content = f.read()
            
            # Check if component uses BasicReferralService
            if 'basic_referral_service.dart' in component_content:
                integration_status = "✅ Uses BasicReferralService"
            else:
                integration_status = "⚠️ No BasicReferralService integration"
                audit_results['issues'].append(f"⚠️ {component_name} missing BasicReferralService integration")
            
            audit_results['ui_components'][component_name] = {
                'exists': True,
                'has_service_integration': 'basic_referral_service.dart' in component_content
            }
            
            print(f"   {integration_status}")
            
        else:
            print(f"❌ {component_name} - Missing")
            audit_results['issues'].append(f"❌ Missing UI component: {component_name}")
            audit_results['ui_components'][component_name] = {'exists': False}
    
    print("\n" + "="*60)
    print("🔗 4. INTEGRATION AUDIT")
    print("="*60)
    
    # 4.1 Check pubspec.yaml dependencies
    print(f"\n🔍 Auditing dependencies...")
    
    if os.path.exists('pubspec.yaml'):
        with open('pubspec.yaml', 'r', encoding='utf-8') as f:
            pubspec_content = f.read()
        
        required_deps = ['supabase_flutter', 'share_plus', 'sizer']
        missing_deps = []
        
        for dep in required_deps:
            if dep in pubspec_content:
                print(f"✅ {dep} dependency found")
            else:
                missing_deps.append(dep)
                print(f"❌ {dep} dependency missing")
        
        if missing_deps:
            audit_results['issues'].append(f"❌ Missing dependencies: {missing_deps}")
        
        audit_results['integration']['dependencies'] = {
            'required': required_deps,
            'missing': missing_deps
        }
    
    # 4.2 Check for old referral service references
    print(f"\n🔍 Checking for old service references...")
    
    old_refs_found = []
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if "'referral_service.dart'" in content or '"referral_service.dart"' in content:
                        old_refs_found.append(file_path)
                except:
                    pass
    
    if old_refs_found:
        audit_results['issues'].append(f"⚠️ Files still referencing old referral_service.dart: {old_refs_found}")
        print(f"⚠️ Old service references found in: {old_refs_found}")
    else:
        print(f"✅ No old referral service references found")
    
    print("\n" + "="*60)
    print("📋 5. AUDIT SUMMARY")
    print("="*60)
    
    total_issues = len(audit_results['issues'])
    
    if total_issues == 0:
        print(f"\n🎉 AUDIT PASSED - No issues found!")
        print(f"✅ QR code and referral system is in excellent condition")
    else:
        print(f"\n⚠️ AUDIT FOUND {total_issues} ISSUES:")
        for i, issue in enumerate(audit_results['issues'], 1):
            print(f"   {i}. {issue}")
    
    # Generate recommendations
    print(f"\n💡 RECOMMENDATIONS:")
    
    if audit_results['database']['referral_codes']['active'] == 0:
        print(f"   1. Generate some test referral codes for testing")
    
    if audit_results['database']['referral_usage']['total_usage'] == 0:
        print(f"   2. Create test usage scenarios to validate SPA distribution")
    
    if total_issues > 0:
        print(f"   3. Fix the {total_issues} issues identified above")
    
    print(f"   4. Consider adding automated tests for the referral system")
    print(f"   5. Monitor referral code usage patterns in production")
    
    # Save audit results
    with open('AUDIT_RESULTS.json', 'w') as f:
        json.dump(audit_results, f, indent=2)
    
    print(f"\n📄 Detailed audit results saved to: AUDIT_RESULTS.json")
    
    return total_issues == 0

if __name__ == "__main__":
    success = audit_qr_referral_system()
    
    if success:
        print(f"\n🟢 AUDIT SUCCESSFUL - System is ready for production")
    else:
        print(f"\n🟡 AUDIT COMPLETED - Please address issues before production")